class profiles::rabbitmq::monitoring (
  String  $hostname          = 'orange-gnu.rmq.cloudamqp.com',
  Integer $port              = 443,
  Boolean $use_ssl           = true,
  String  $check_interval    = '15s',
  String  $exchanges_regexes = '[".*"]',
  String  $queues_regexes    = '[".*"]',
  String  $vhosts,           # example value: '["udb3","uitid-prod","mailjet-prod","mpm-prod","projectaanvraag-prod"]'
) inherits ::profiles {

  $rabbitmq_credentials = lookup('vault:testproject/rabbitmq')

  profiles::newrelic::infrastructure::integration { 'rabbitmq':
    check_interval => $check_interval,
    labels         => {
                        'role'               => 'rabbitmq'
                      },
    configuration  => {
                        'METRICS'            => true,
                        'INVENTORY'          => true,
                        'CA_BUNDLE_FILE'     => "/etc/ssl/certs/ca-certificates.crt",
                        'USE_SSL'            => $use_ssl,
                        'HOSTNAME'           => $hostname,
                        'PORT'               => $port,
                        'USERNAME'           => $rabbitmq_credentials['username'],
                        'PASSWORD'           => $rabbitmq_credentials['password'],
                        'EXCHANGES_REGEXES'  => $exchanges_regexes,
                        'QUEUES_REGEXES'     => $queues_regexes,
                        'VHOSTS: '           => $vhosts
                      },
  }
}
