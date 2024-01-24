class profiles::mysql::logging inherits ::profiles {

  include profiles::logrotate

  realize User['mysql']

  logrotate::rule { 'mysql-server':
    ensure => 'absent'
  }

  logrotate::rule { 'mysql-server-slow-query':
    path         => '/var/log/mysql/slow-query.log',
    rotate       => 30,
    create_owner => 'mysql',
    create_group => 'adm',
    copytruncate => false,
    postrotate   => '/usr/bin/mysql -e "select @@global.slow_query_log into @sq_log_save; set global slow_query_log=off; select sleep(5); FLUSH SLOW LOGS; select sleep(10); set global slow_query_log=@sq_log_save;"',
    require      => User['mysql'],
    *            => $profiles::logrotate::default_rule_attributes
  }

  logrotate::rule { 'mysql-server-error':
    path         => '/var/log/mysql/error.log',
    rotate       => 30,
    create_owner => 'mysql',
    create_group => 'adm',
    copytruncate => false,
    postrotate   => '/usr/bin/mysqladmin --defaults-file="/root/.my.cnf" flush-logs error',
    require      => User['mysql'],
    *            => $profiles::logrotate::default_rule_attributes
  }
}
