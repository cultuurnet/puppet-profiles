define profiles::glassfish::domain::service_alias {

  include ::profiles
  include ::profiles::glassfish

  $service_alias = $title

  systemd::dropin_file { "glassfish domain service alias ${service_alias}":
    unit           => "glassfish-${service_alias}.service",
    filename       => "${service_alias}.conf",
    content        => "[Install]\nAlias=${service_alias}.service",
    notify_service => false,
    daemon_reload  => false,
    require        => Class['profiles::glassfish']
  }

  exec { "re-enable glassfish domain (${service_alias})":
    command     => "systemctl reenable glassfish-${service_alias}",
    path        => ['/usr/sbin', '/usr/bin'],
    refreshonly => true,
    logoutput   => 'on_failure',
    subscribe   => Systemd::Dropin_file["glassfish domain service alias ${service_alias}"]
  }
}
