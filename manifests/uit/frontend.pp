class profiles::uit::frontend (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases       = [],
  Boolean                       $deployment          = true,
  Stdlib::Ipv4                  $service_address     = '127.0.0.1',
  Integer                       $service_port        = 3000,
  Optional[String]              $redirect_source     = undef,
  Boolean                       $maintenance_page    = false,
  Boolean                       $deployment_page     = false
) inherits ::profiles {

  $basedir              = '/var/www/uit-frontend'
  $rewrites_compression = [{
                            comment      => 'Serve brotli compressed assets for supported clients',
                            rewrite_cond => [
                                              '%{HTTP:Accept-encoding} "br"',
                                              "${basedir}/packages/app/.output/public%{REQUEST_FILENAME}.br -f",
                                            ],
                            rewrite_rule => "^/(css/|img/|js/|icons/|_nuxt/)(.*)\$ ${basedir}/packages/app/.output/public/\$1\$2.br [E=brotli]"
                          }, {
                            comment      => 'Serve gzip compressed assets for supported clients',
                            rewrite_cond => [
                                              '%{HTTP:Accept-encoding} "gzip"',
                                              "${basedir}/packages/app/.output/public%{REQUEST_FILENAME}.gz -f",
                                            ],
                            rewrite_rule => "^/(css/|img/|js/|icons/|_nuxt/)(.*)\$ ${basedir}/packages/app/.output/public/\$1\$2.gz [E=gzip]"
                          }, {
                            comment      => 'Do not compress pre-compressed content in transfer',
                            rewrite_rule => [
                                              '\.css\.(gz|br)$ - [T=text/css,E=no-gzip:1,E=no-brotli:1]',
                                              '\.js\.(gz|br)$ - [T=text/javascript,E=no-gzip:1,E=no-brotli:1]',
                                              '\.svg\.(gz|br)$ - [T=image/svg+xml,E=no-gzip:1,E=no-brotli:1]'
                                            ]
                          }]
  $headers_compression  = [
                            'append Content-Encoding "br" "env=brotli"',
                            'append Content-Encoding "gzip" "env=gzip"',
                            'append Vary "Accept-Encoding" "env=brotli"',
                            'append Vary "Accept-Encoding" "env=gzip"'
                          ]

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::firewall::rules
  include ::profiles::nodejs
  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  if $redirect_source {
    file { 'uit-frontend-migration-script':
      ensure  => 'file',
      path    => "${basedir}/migrate.sh",
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0755',
      content => template('profiles/uit/frontend/migrate.sh.erb'),
      require => [File[$basedir], Group['www-data'], User['www-data']],
      notify  => Class['apache::service']
    }

    file { 'uit-frontend-redirects':
      ensure  => 'file',
      path    => "${basedir}/.redirect",
      owner   => 'www-data',
      group   => 'www-data',
      source  => $redirect_source,
      require => [File[$basedir], Group['www-data'], User['www-data']],
      notify  => Class['apache::service']
    }

    $vhost_custom_fragment = "Include ${basedir}/.redirect"
  } else {
    $vhost_custom_fragment = undef
  }

  if $maintenance_page {
    $maintenance_page_location       = '/maintenance/'
    $maintenance_error_code          = 503
    $rewrite_maintenance_page        = {
                                         comment      => 'Maintenance page',
                                         rewrite_cond => [
                                                           "%{DOCUMENT_ROOT}${maintenance_page_location}index.html -f",
                                                           '%{DOCUMENT_ROOT}/maintenance.enabled -f',
                                                           "%{REQUEST_URI} !^${maintenance_page_location}"
                                                         ],
                                         rewrite_rule => "^ - [R=${maintenance_error_code},L]"
                                       }
    $error_document_maintenance_page = {
                                         error_code => $maintenance_error_code,
                                         document   => "${maintenance_page_location}index.html"
                                       }

    file { 'uit-maintenance-page':
      ensure  => 'directory',
      path    => "${basedir}${maintenance_page_location}",
      recurse => true,
      purge   => true,
      source  => 'puppet:///modules/profiles/uit/frontend/maintenance',
      owner   => 'www-data',
      group   => 'www-data',
      require => [File[$basedir], Group['www-data'], User['www-data']]
    }
  } else {
    $maintenance_page_location       = undef
    $rewrite_maintenance_page        = undef
    $error_document_maintenance_page = undef
  }

  if $deployment_page {
    $deployment_page_location       = '/deployment/'
    $deployment_error_code          = 504
    $rewrite_deployment_page        = {
                                        comment      => 'Deployment in progress page',
                                        rewrite_cond => [
                                                          "%{DOCUMENT_ROOT}${deployment_page_location}index.html -f",
                                                          '%{DOCUMENT_ROOT}/api.deployment.enabled -f [OR]',
                                                          '%{DOCUMENT_ROOT}/frontend.deployment.enabled -f [OR]',
                                                          '%{DOCUMENT_ROOT}/cms.deployment.enabled -f [OR]',
                                                          '%{DOCUMENT_ROOT}/deployment.enabled -f',
                                                          "%{REQUEST_URI} !^${deployment_page_location}"
                                                        ],
                                        rewrite_rule => "^ - [R=${deployment_error_code},L]"
                                      }
    $error_document_deployment_page = {
                                        error_code => $deployment_error_code,
                                        document   => "${deployment_page_location}index.html"
                                      }

    file { 'uit-deployment-page':
      ensure  => 'directory',
      path    => "${basedir}${deployment_page_location}",
      recurse => true,
      purge   => true,
      source  => 'puppet:///modules/profiles/uit/frontend/deployment',
      owner   => 'www-data',
      group   => 'www-data',
      require => [File[$basedir], Group['www-data'], User['www-data']]
    }
  } else {
    $deployment_page_location       = undef
    $rewrite_deployment_page        = undef
    $error_document_deployment_page = undef
  }

  if $deployment {
    class { 'profiles::uit::frontend::deployment':
      service_address => $service_address,
      service_port    => $service_port
    }

    Class['profiles::nodejs'] -> Class['profiles::uit::frontend::deployment']
    Class['profiles::uit::frontend::deployment'] -> Apache::Vhost["${servername}_80"]
  }

  realize Firewall['300 accept HTTP traffic']

  apache::vhost { "${servername}_80":
    servername         => $servername,
    serveraliases      => [$serveraliases].flatten,
    docroot            => $basedir,
    manage_docroot     => false,
    request_headers    => [
                            'unset Proxy early'
                          ],
    port               => 80,
    access_log_format  => 'uit_frontend_json',
    access_log_env_var => '!nolog',
    directories        => [{
                            path           => '/',
                            options        => ['Indexes', 'MultiViews'],
                            allow_override => ['All'],
                            require        => { enforce => 'all', requires => ['all granted'] }
                          },
                          {
                            path           => '/(css/|img/|js/|icons/|_nuxt/|sw.js)',
                            provider       => 'locationmatch',
                            headers        => [
                                                'set Cache-Control "max-age=31536000, public"',
                                                'unset Last-Modified "expr=%{REQUEST_URI} =~ m#^/_nuxt/#"'
                                              ]
                          }],
    proxy_pass         => [{
                            path                => '/',
                            url                 => "http://${service_address}:${service_port}/",
                            no_proxy_uris       => [$maintenance_page_location, $deployment_page_location].filter |$item| { $item },
                            no_proxy_uris_match => ['^/(css/|img/|js/|icons/|_nuxt/|sw.js)']
                          }],
    aliases            => [{
                            aliasmatch => '^/(css/|img/|js/|icons/|_nuxt/|sw.js)(.*)$',
                            path       => "${basedir}/packages/app/.output/public/\$1\$2"
                          }],
    rewrites           => [ $rewrite_maintenance_page, $rewrite_deployment_page ].filter |$item| { $item } + $rewrites_compression,
    headers            => $headers_compression,
    error_documents    => [ $error_document_maintenance_page, $error_document_deployment_page ].filter |$item| { $item },
    custom_fragment    => $vhost_custom_fragment,
    setenvif           => [
                            'X-Forwarded-Proto "https" HTTPS=on',
                            'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                          ],
    require => [Class['profiles::apache'], File['/var/www/uit-frontend']]
  }

  # include ::profiles::uit::frontend::monitoring
  # include ::profiles::uit::frontend::metrics
  # include ::profiles::uit::frontend::backup
  # include ::profiles::uit::frontend::logging
}
