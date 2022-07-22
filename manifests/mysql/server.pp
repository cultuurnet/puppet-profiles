class profiles::mysql::server (
  Integer $max_open_files = 1024
) inherits ::profiles {

  systemd::dropin_file { 'mysql override.conf':
    unit          => 'mysql.service',
    filename      => 'override.conf',
    content       => "[Service]\nLimitNOFILE=${max_open_files}",
    daemon_reload => 'eager'
  }

  include ::mysql::server

  Systemd::Dropin_file['mysql override.conf'] -> Class['mysql::server']
}
