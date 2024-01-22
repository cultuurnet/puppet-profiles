class profiles::mysql::server (
  Optional[String] $root_password  = undef,
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Integer          $max_open_files = 1024
) inherits ::profiles {

  $root_user = 'root'
  $host      = '127.0.0.1'
  $options   = {
                 'client' => { 'default-character-set' => 'utf8mb4' },
                 'mysql'  => { 'default-character-set' => 'utf8mb4' },
                 'mysqld' => {
                               'character-set-client-handshake' => 'false',
                               'character-set-server'           => 'utf8mb4',
                               'collation-server'               => 'utf8mb4_unicode_ci',
                               'bind-address'                   => '0.0.0.0',
                               'ignore-db-dir'                  => 'lost+found',
                               'skip-name-resolve'              => 'true',
                               'innodb_file_per_table'          => 'ON',
                               'slow_query_log'                 => 'ON',
                               'slow_query_log_file'            => '/var/log/mysql/slow-query.log',
                               'long_query_time'                => '4'
                             }
               }

  realize Group['mysql']
  realize User['mysql']

  if $lvm {

    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'mysqldata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/mysql',
      fs_type      => 'ext4',
      owner        => 'mysql',
      group        => 'mysql',
      require      => [Group['mysql'], User['mysql']],
      before       => Class['mysql::server']
    }

    file { '/var/lib/mysql':
      ensure  => 'link',
      target  => '/data/mysql',
      force   => true,
      owner   => 'mysql',
      group   => 'mysql',
      require => [File['/var/lib/mysql'], Profiles::Lvm::Mount['mysqldata']],
      before  => Class['mysql::server']
    }
  }

  file { 'root_my_cnf':
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/mysql/my.cnf.erb'),
    before  => Class['mysql::server']
  }

  systemd::dropin_file { 'mysql override.conf':
    unit          => 'mysql.service',
    filename      => 'override.conf',
    content       => "[Service]\nLimitNOFILE=${max_open_files}"
  }

  class { ::mysql::server:
    root_password      => $root_password,
    create_root_my_cnf => false,
    restart            => true,
    override_options   => $options
  }

  include profiles::mysql::logging

  Group['mysql'] -> Class['mysql::server']
  User['mysql'] -> Class['mysql::server']
  Systemd::Dropin_file['mysql override.conf'] -> Class['mysql::server']
  Systemd::Dropin_file['mysql override.conf'] ~> Class['mysql::server::service']
  Class['mysql::server'] -> Class['profiles::mysql::logging']
}
