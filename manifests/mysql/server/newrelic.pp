class profiles::mysql::server::newrelic (
  String $mysql_user     = lookup('data::mysql::newrelic::user',     String, 'first', undef),
  String $mysql_password = lookup('data::mysql::newrelic::password', String, 'first', undef),
  String $license_key    = lookup('data::newrelic::license_key',     String, 'first', undef),
  String $check_interval = '30s',
  String $slow_query_log = '/var/log/mysql/slow-query.log'
) inherits ::profiles {

  profiles::mysql::app_user { "${mysql_user}@*":
    password => $mysql_password,
    readonly => true
  }

  $slow_query_log_config = {
    logs => [{
      name       => "mysql-slow-query-log",
      file       => " /var/log/mysql/slow-query.log",
      attributes => { logtype => "mysql-slow-query-log" }
    }]
  }

  $nri_mysql_config = {
    integrations =>[{
      name             => 'nri-mysql',
      interval         => $check_interval,
      labels           => { env => $evironment },
      inventory_source => 'config/mysql',
      env              => {
        'HOSTNAME'          => $facts['networking']['fqdn'],
        'USERNAME'          => $mysql_user,
        'PASSWORD'          => $mysql_password,
        'PORT'              => 3306,
        'REMOTE_MONITORING' => true
      }
    }]
  }

  class { 'profiles::newrelic_infra':
    license_key => $license_key,
    integrations => {
      nri-mysql => { ensure => 'present' }
    },
    logging     => {
      mysql-slow-query-log => {
        ensure     => 'present',
        configfile => to_yaml($slow_query_log_config)
      }
    },
    integration_config_files => {
      nri-mysql => {
        integration_config => {
          ensure     => 'present',
          configfile => to_yaml($nri_mysql_config)
        }
      }
    }
  }
}
