define profiles::php::fpm_service_alias {

  include ::profiles
  include ::profiles::php

  $service_alias = $title
  $php_version   = $profiles::php::version

  systemd::dropin_file { "php-fpm service alias ${service_alias}":
    unit           => "php${php_version}-fpm.service",
    filename       => "${service_alias}.conf",
    content        => "[Install]\nAlias=${service_alias}.service",
    notify_service => false,
    daemon_reload  => false,
    require        => Class['profiles::php']
  }

  exec { "re-enable php${php_version}-fpm (${service_alias})":
    command     => "systemctl reenable php${php_version}-fpm",
    path        => ['/usr/sbin', '/usr/bin'],
    refreshonly => true,
    logoutput   => 'on_failure',
    subscribe   => Systemd::Dropin_file["php-fpm service alias ${service_alias}"]
  }
}
