class profiles::uitdatabank::search_api::publish_message (
  String                    $version           = 'present',
  Optional[String]          $rabbitmq_host     = undef,
  Integer                   $rabbitmq_port     = 5672,
  Optional[String]          $rabbitmq_username = undef,
  Optional[String]          $rabbitmq_password = undef,
  Optional[String]          $rabbitmq_vhost    = undef,
  Optional[String]          $rabbitmq_exchange = undef,
  Optional[Stdlib::Httpurl] $source_url        = undef,
  Integer                   $delay_ms          = 0
) inherits ::profiles {

  include profiles::ruby

  realize Apt::Source['publiq-tools']

  package { 'uitdatabank-publish-message':
    ensure  => $version,
    require => Apt::Source['publiq-tools']
  }

  file { 'uitdatabank-publish-message.conf':
    ensure  => 'file',
    path    => '/etc/uitdatabank/publish-updated-message.conf',
    content => template('profiles/uitdatabank/search_api/publish-updated-message.conf.erb'),
    require => Package['uitdatabank-publish-message']
  }
}
