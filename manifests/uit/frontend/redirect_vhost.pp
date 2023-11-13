define profiles::uit::frontend::redirect_vhost (
  String                        $redirect_source = undef,
  Variant[String,Array[String]] $aliases         = []

) inherits ::profiles {

  file { "${title}-redirects":
    ensure  => 'file',
    path    => "/var/www/.redirect.${title}",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $redirect_source,
    require => Class['profiles::uit::frontend'],
    notify  => Class['apache::service']
  }

  apache::vhost { "${title}_80":
    servername         => $title,
    serveraliases      => $aliases,
    docroot            => '/var/www',
    manage_docroot     => false,
    request_headers    => ['unset Proxy early'],
    port               => 80,
    access_log_format  => 'extended_json',
    access_log_env_var => '!nolog',
    custom_fragment    => "Include /var/www/.redirect.${title}",
    setenvif           => [
                            'X-Forwarded-Proto "https" HTTPS=on',
                            'X-Forwarded-For "^(\d{1,3}+\.\d{1,3}+\.\d{1,3}+\.\d{1,3}+).*" CLIENT_IP=$1'
                          ],
    require => File["${title}-redirects"]
  }
}
