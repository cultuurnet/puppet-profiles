class profiles::mysql::rds (
  String $host
) inherits ::profiles {

  $rds_mysqld_version = lookup('terraform::rds::mysqld_version', Optional[String], 'first', undef)

  realize File['/etc/puppetlabs/facter/facts.d']

  if $rds_mysqld_version {
    file { 'mysqld_version_external_fact':
      ensure  => 'file',
      path    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "mysqld_version=${rds_mysqld_version}",
      require => File['/etc/puppetlabs/facter/facts.d']
    }

    profiles::mysql::root_my_cnf { $host:
      database_user     => lookup('terraform::rds::user'),
      database_password => lookup('terraform::rds::password')
    }
  }
}
