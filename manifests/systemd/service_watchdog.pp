define profiles::systemd::service_watchdog (
  Enum['present', 'absent'] $ensure                 = 'present',
  String                    $service                = $title,
  Integer                   $timeout_seconds        = 10,
  Integer                   $check_interval_seconds = floor($timeout_seconds / 4),
  String                    $healthcheck            = '/usr/bin/true'
) {

  include ::profiles

  if ($check_interval_seconds >= $timeout_seconds) {
    fail("Defined resource Profiles::Systemd::Service_watchdog[${title}]: 'check_interval_seconds' should be smaller than 'timeout_seconds'")
  }

  file { "${title}-watchdog":
    ensure  => $ensure ? {
                 'absent'  => 'absent',
                 'present' => 'file'
               },
    path    => "/usr/local/bin/${title}-watchdog",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('profiles/systemd/service_watchdog.erb'),
    notify  => Service["${title}-watchdog"]
  }

  systemd::unit_file { "${title}-watchdog.service":
    ensure  => $ensure ? {
                 'absent'  => 'absent',
                 'present' => 'file'
               },
    content => template('profiles/systemd/service_watchdog.service.erb'),
    notify  => Service["${title}-watchdog"]
  }

  service { "${title}-watchdog":
    ensure    => $ensure ? {
                   'absent'  => 'stopped',
                   'present' => 'running'
                 },
    enable    => $ensure ? {
                   'absent'  => false,
                   'present' => true
                 },
    hasstatus => true
  }

  systemd::dropin_file { "${title}_override.conf":
    ensure         => $ensure,
    unit           => "${service}.service",
    filename       => 'override.conf',
    notify_service => false,
    content        => "[Unit]\nRequires=${title}-watchdog.service\nAfter=network.target ${title}-watchdog.service",
    require        => Service["${title}-watchdog"]
  }
}
