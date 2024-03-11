class profiles::mysql::server (
  Optional[String]                                                              $root_password         = undef,
  Stdlib::IP::Address::V4                                                       $listen_address        = '127.0.0.1',
  Boolean                                                                       $lvm                   = false,
  Optional[String]                                                              $volume_group          = undef,
  Optional[String]                                                              $volume_size           = undef,
  Integer                                                                       $max_open_files        = 1024,
  Integer                                                                       $long_query_time       = 2,
  Enum['READ-COMMITTED', 'REPEATABLE-READ', 'READ-UNCOMMITTED', 'SERIALIZABLE'] $transaction_isolation = 'REPEATABLE-READ'

) inherits ::profiles {

  $root_user = 'root'
  $options   = {
                 'client' => { 'default-character-set' => 'utf8mb4' },
                 'mysql'  => { 'default-character-set' => 'utf8mb4' },
                 'mysqld' => {
                               'character-set-client-handshake' => 'false',
                               'character-set-server'           => 'utf8mb4',
                               'collation-server'               => 'utf8mb4_unicode_ci',
                               'bind-address'                   => $listen_address,
                               'skip-name-resolve'              => 'true',
                               'innodb_file_per_table'          => 'ON',
                               'slow_query_log'                 => 'ON',
                               'slow_query_log_file'            => '/var/log/mysql/slow-query.log',
                               'long_query_time'                => "${long_query_time}",
                               'transaction_isolation'          => $transaction_isolation
                             }
               }

  include profiles::firewall::rules

  if $listen_address == '127.0.0.1' {
    profiles::mysql::my_cnf { 'root':
      database_user     => $root_user,
      database_password => $root_password,
      host              => 'localhost',
      before            => Class['mysql::server']
    }
  } else {
    realize Firewall['400 accept mysql traffic']

    if $facts['mysqld_version'] {
      @@file { 'mysqld_version_external_fact':
        ensure  => 'file',
        path    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "mysqld_version=${facts['mysqld_version']}",
        tag     => ['mysqld_version', $facts['networking']['fqdn']]
      }
    }

    @@profiles::mysql::my_cnf { 'root':
      database_user     => $root_user,
      database_password => $root_password,
      host              => $facts['networking']['fqdn'],
      before            => Class['mysql::server']
    }

    Profiles::Mysql::My_cnf <<| title == 'root' and host == $facts['networking']['fqdn'] |>>
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

    file { '/data/mysql/lost+found':
      ensure  => 'absent',
      force   => true,
      require => Profiles::Lvm::Mount['mysqldata'],
      before  => Class['mysql::server']
    }

    file { '/var/lib/mysql':
      ensure  => 'directory',
      owner   => 'mysql',
      group   => 'mysql',
      require => Profiles::Lvm::Mount['mysqldata'],
      before  => Class['mysql::server']
    }

    mount { '/var/lib/mysql':
      ensure  => 'mounted',
      device  => '/data/mysql',
      fstype  => 'none',
      options => 'rw,bind',
      notify  => Class['mysql::server::service'],
      require => [Profiles::Lvm::Mount['mysqldata'], File['/var/lib/mysql']],
      before  => Class['mysql::server']
    }
  }

  systemd::dropin_file { 'mysql override.conf':
    unit          => 'mysql.service',
    filename      => 'override.conf',
    content       => "[Service]\nLimitNOFILE=${max_open_files}"
  }

  class { ::mysql::server:
    root_password      => $root_password,
    package_name       => 'mysql-server',
    service_name       => 'mysql',
    create_root_my_cnf => false,
    managed_dirs       =>  [],
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
