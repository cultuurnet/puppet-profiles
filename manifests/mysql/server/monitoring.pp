class profiles::mysql::server::monitoring inherits ::profiles {

  $database_user     = 'newrelic'
  $database_password = fqdn_rand_string(20, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', $database_user)

  profiles::mysql::app_user { "${database_user}@*":
    password => $database_password,
    readonly => true,
    remote   => true
  }

  profiles::newrelic::infrastructure::integration { 'mysql':
    configuration => {
                       'HOSTNAME'          => $facts['networking']['fqdn'],
                       'PORT'              => 3306,
                       'USERNAME'          => $database_user,
                       'PASSWORD'          => $database_password,
                       'METRICS'           => true,
                       'INVENTORY'         => true,
                       'REMOTE_MONITORING' => true
                     },
    require       => Profiles::Mysql::App_user["${database_user}@*"]
  }

  profiles::newrelic::infrastructure::logging { 'mysql-error-log':
    source => '/var/log/mysql/error.log'
  }

  profiles::newrelic::infrastructure::logging { 'mysql-slow-query-log':
    source => '/var/log/mysql/slow-query.log'
  }
}
