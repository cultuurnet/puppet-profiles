define profiles::newrelic::infrastructure::integration (
  String $check_interval = '30s',
  Hash   $labels         = {},
  Hash   $conditions     = {},
  Hash   $configuration  = {}
) {

  include ::profiles

  $config_dir       = '/etc/newrelic-infra/integrations.d'
  $integration_name = $title ? {
                        /^nri-/ => regsubst($title, /^nri-/, ''),
                        default => $title
                      }

  realize Apt::Source['newrelic-infra']

  package { "nri-${integration_name}":
    ensure  => 'latest',
    require => Apt::Source['newrelic-infra']
  }

  file { "${integration_name}-config.yml":
    ensure   => file,
    path     => "${config_dir}/${integration_name}-config.yml",
    content  => template('profiles/newrelic/infrastructure/integration-config.yml.erb')
  }
}
