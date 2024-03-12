class profiles::mysql::rds inherits ::profiles {

  $rds_mysqld_version = lookup('terraform::rds::mysqld_version', Optional[String], 'first', undef)

  realize Package['mysql-client']

  if $rds_mysqld_version {
    $rds_host = lookup('terraform::rds::host')

    file { 'mysqld_version_external_fact':
      ensure  => 'file',
      path    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "mysqld_version=${rds_mysqld_version}"
    }

    profiles::mysql::root_my_cnf { $rds_host:
      database_user     => lookup('terraform::rds::user'),
      database_password => lookup('terraform::rds::password')
    }
  }
}
