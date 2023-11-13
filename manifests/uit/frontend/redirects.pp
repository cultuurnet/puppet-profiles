class profiles::uit::frontend::redirects inherits ::profiles {

  uiv_redirects = {
    'prettiggeleerd' => {
      'aliases' => ['www.prettiggeleerd.be']
    },
    'kampzoeker' => {
      'aliases' => ['www.kampzoeker.be','kampenzoeker.be','www.kampenzoeker.be','mijnkindopkamp.be','www.mijnkindopkamp.be']
    },
    'bill' => {
      'aliases' => ['www.bill.be']
    },
    'uitmetvlieg' => {
      'aliases' => ['www.uitmetvlieg.be']
    }
  }

  $uiv_redirects.each |$name, $attributes| {
    file { "${name}-redirects":
      ensure  => 'file',
      path    => "/var/www/.redirect.${name}",
      owner   => 'www-data',
      group   => 'www-data',
      source  => "puppet:///modules/appconfig/uit/production/frontend/redirect.${name}",
      require => Class['profiles::uit::frontend'],
      notify  => Class['apache::service']
    }

    apache::vhost { "${name}.be_80":
      servername         => "${name}.be",
      serveraliases      => $attributes['aliases'],
      docroot            => '/var/www',
      manage_docroot     => false,
      request_headers    => ['unset Proxy early'],
      port               => 80,
      access_log_format  => 'extended_json',
      access_log_env_var => '!nolog',
      custom_fragment    => "Include /var/www/.redirect.${name}",
      setenvif           => [
                              'X-Forwarded-Proto "https" HTTPS=on',
                              'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                            ],
      require => File["${name}-redirects"]
    }
  }
}
