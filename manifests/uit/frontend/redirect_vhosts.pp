define profiles::uit::frontend::redirect_vhosts (
  String                        $redirect_source = undef,
  Variant[String,Array[String]] $aliases         = []

) {

  file { "${title}-redirects":
    ensure  => 'file',
    path    => "/var/www/.redirect.${title}",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $redirect_source,
    notify  => Class['apache::service']
  }

  apache::vhost { "${title}_80":
    servername         => $title,
    serveraliases      => $aliases,
    docroot            => '/var/www',
    manage_docroot     => false,
    request_headers    => $profiles::apache::defaults::request_headers,
    port               => 80,
    access_log_format  => 'extended_json',
    access_log_env_var => '!nolog',
    custom_fragment    => "Include /var/www/.redirect.${title}",
    setenvif           => $profiles::apache::defaults::setenvif,
    require            => File["${title}-redirects"]
  }
}
