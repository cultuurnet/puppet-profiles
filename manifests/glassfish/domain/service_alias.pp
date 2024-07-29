define profiles::glassfish::domain::service_alias {

  include ::profiles
  include ::profiles::glassfish

  file { "${title} glassfish domain service alias link":
    ensure  => 'link',
    path    => "/etc/systemd/system/${title}.service",
    target  => "/lib/systemd/system/glassfish-${title}.service",
    require => Class['profiles::glassfish'],
    notify  => Systemd::Daemon_reload[$title]
  }

  file { "/etc/systemd/system/glassfish-${title}.service.d":
    ensure => 'absent',
    force  => true,
    notify  => Systemd::Daemon_reload[$title]
  }

  systemd::daemon_reload { $title: }
}
