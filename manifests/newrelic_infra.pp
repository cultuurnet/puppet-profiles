# == Class: profiles::newrelic_infra
#
# === Required Parameters
# [*license_key*]
#   New Relic license key
#
# [*manage_repo*]
#   Optionally disable creating any of the repo resources and control outside
#   of this module.
#
# [*integrations*]
#   Optional configuration hash for an integration.
#   If undefined, only basic system metrics will be monitored
#   by the newrelic-infra agent.
#
#   Hiera config example:
#   ---
#   profiles::newrelic_infra::integrations:
#   'nri-mysql':
#     ensure: 'present'
#     configfile_content: |
#       integrations:
#         - name: nri-mysql
#           env:
#             HOSTNAME: localhost
#             PORT: 3306
#             USERNAME: newrelic
#             PASSWORD: <YOUR_SELECTED_PASSWORD>
#             REMOTE_MONITORING: true
#           interval: 30s
#           labels:
#             env: production
#             role: write-replica
#           inventory_source: config/mysql
#
# List of integrations present newrelic apt repo
# https://download.newrelic.com/infrastructure_agent/linux/apt
#
# nri-apache
# nri-cassandra
# nri-consul
# nri-couchbase
# nri-docker
# nri-elasticsearch
# nri-f5
# nri-haproxy
# nri-ibmmq
# nri-jmx
# nri-kafka
# nri-memcached
# nri-mongodb
# nri-mssql
# nri-mysql
# nri-nagios
# nri-nginx
# nri-oracledb
# nri-postgresql
# nri-powerdns
# nri-rabbitmq
# nri-redis
# nri-snmp
# nri-varnish
# nri-vsphere
#
# === Authors
#
# Paul Herbosch <paul@publiq.be>
#
class profiles::newrelic_infra (
  String                  $license_key,
  Boolean                 $manage_repo  = false,
  Optional[Variant[Hash]] $integrations = undef
) {

  realize Apt::Source['newrelic-infra']

  class { 'newrelic_infra::agent':
    ensure      => 'latest',
    license_key => $license_key,
    manage_repo => $manage_repo
  }

  if $integrations {
    class { 'newrelic_infra::integrations':
      integrations => $integrations
    }

    $integrations.each |$key,$value| {
      if $value['ensure'] == "present" {
        file { "${key}-config.yaml":
          ensure  => file,
          path    => '/etc/newrelic-infra/integrations.d/${key}-config.yaml',
          content => $value['configfile_content'],
          notify  => Service['newrelic-infra']
        }
      }
      else {
        file { "${key}-config.yaml":
          ensure  => absent,
          path    => '/etc/newrelic-infra/integrations.d/${key}-config.yaml',
          notify  => Service['newrelic-infra']
        }
      }
    }
  }
}
