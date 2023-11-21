define profiles::glassfish::domain::service(
  Enum['present', 'absent']  $ensure = 'present',
  Enum['running', 'stopped'] $status = 'running'
) {

  include ::profiles

  systemd::unit_file { "${title}.service":
    ensure        => $ensure,
    path          => '/lib/systemd/system',
    content       => template('profiles/glassfish/domain/service.erb'),
    daemon_reload => true
  }

  if $ensure == 'present' {
    service { $title:
      ensure    => $status,
      hasstatus => true,
      enable    => $status ? {
                     'running' => true,
                     'stopped' => false
                   },
      require   => Systemd::Unit_file["${title}.service"]
    }
  }
}
