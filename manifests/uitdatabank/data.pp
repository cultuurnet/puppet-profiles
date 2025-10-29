class profiles::uitdatabank::data (
  Boolean $redis = true,
  Boolean $mysql = true
) inherits ::profiles {

  realize Package['amqp-tools']

  if $redis {
    include profiles::redis
  }

  if $mysql {
    include profiles::mysql::server
  }
}

