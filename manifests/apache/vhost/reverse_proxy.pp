define profiles::apache::vhost::reverse_proxy (
  Stdlib::Httpurl                $destination,
  Optional[String]               $certificate           = undef,
  Enum['on', 'off', 'nodecode']  $allow_encoded_slashes = 'off',
  Boolean                        $preserve_host         = false,
  Boolean                        $support_websockets    = false,
  Boolean                        $auth_openid_connect   = false,
  Hash                           $proxy_params          = {},
  Variant[String, Array[String]] $proxy_keywords        = [],
  Variant[String, Array[String]] $aliases               = [],
  String                         $access_log_format     = 'extended_json'
) {

  include ::profiles
  include ::profiles::firewall::rules
  include ::profiles::apache

  unless $title =~ Stdlib::Httpurl {
    fail("Defined resource type Profiles::Apache::Vhost::Reverse_proxy[${title}] expects the title to be a valid HTTP(S) URL")
  }

  $transport = split($title, ':')[0]
  $servername = split($title, '/')[-1]

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Reverse_proxy[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https        = true
    $port         = 443
    $ssl_cert     = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key      = "/etc/ssl/private/${certificate}.key"
    $reverse_urls = [$destination, "http://${servername}/"]

    include ::profiles::certificates

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https        = false
    $port         = 80
    $ssl_cert     = undef
    $ssl_key      = undef
    $reverse_urls = $destination

    realize Firewall['300 accept HTTP traffic']
  }

  if $destination =~ /^https/ {
    $https_destination    = true
  } else {
    $https_destination    = false
  }

  if $support_websockets {
    include apache::mod::proxy_wstunnel

    $websockets_destination = regsubst($destination,'^http(.*)/?$','ws\\1')

    $rewrites = [ {
                    'comment'      => 'Proxy Websocket support',
                    'rewrite_cond' => [ '%{HTTP:Upgrade} =websocket [NC]'],
                    'rewrite_rule' => "^/(.*) ${websockets_destination}\$1 [P,L]"
                } ]
  } else {
    $rewrites = undef
  }

  if $auth_openid_connect {
    include apache::mod::authn_core

    $openid_connect_directories = [{
                                    'path'      => '/',
                                    'provider'  => 'location',
                                    'auth_type' => 'openid-connect',
                                    'require'   => 'valid-user'
                                  }]
    $openid_connect_settings    = {
                                    'ProviderMetadataURL' => lookup('data::openid::provider_metadata_url', Optional[String], 'first', undef),
                                    'ClientID'            => lookup('data::openid::client_id', Optional[String], 'first', undef),
                                    'ClientSecret'        => lookup('data::openid::client_secret', Optional[String], 'first', undef),
                                    'RedirectURI'         => "https://${servername}/redirect_uri",
                                    'CryptoPassphrase'    => fqdn_rand_string(32)
                                  }
    $no_proxy_uris              = ['/redirect_uri']
  } else {
    $openid_connect_directories = []
    $openid_connect_settings    = undef
    $no_proxy_uris              = []
  }

  apache::vhost { "${servername}_${port}":
    servername            => $servername,
    serveraliases         => $aliases,
    port                  => $port,
    ssl                   => $https,
    ssl_cert              => $ssl_cert,
    ssl_key               => $ssl_key,
    docroot               => '/var/www/html',
    manage_docroot        => false,
    access_log_format     => $access_log_format,
    directories           => $openid_connect_directories,
    auth_oidc             => $auth_openid_connect,
    oidc_settings         => $openid_connect_settings,
    setenvif              => $profiles::apache::defaults::setenvif,
    request_headers       => $profiles::apache::defaults::request_headers + [
                               "setifempty X-Forwarded-Port \"${port}\"",
                               "setifempty X-Forwarded-Proto \"${transport}\""
                             ],
    ssl_proxyengine       => $https_destination,
    allow_encoded_slashes => $allow_encoded_slashes,
    proxy_preserve_host   => $preserve_host,
    rewrites              => $rewrites,
    proxy_pass            => {
                               'path'          => '/',
                               'url'           => $destination,
                               'keywords'      => [$proxy_keywords].flatten,
                               'reverse_urls'  => $reverse_urls,
                               'params'        => $proxy_params,
                               'no_proxy_uris' => $no_proxy_uris
                             }
  }
}
