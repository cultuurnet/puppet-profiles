define profiles::php::fpm_service_alias {

  include ::profiles
  include ::profiles::php

  file { "${title} php-fpm service alias link":
    ensure  => 'link',
    path    => "/etc/systemd/system/${title}.service",
    target  => '/etc/systemd/system/php-fpm.service',
    require => Class['profiles::php'],
    notify  => Systemd::Daemon_reload[$title]
  }

  systemd::daemon_reload { $title: }
}
