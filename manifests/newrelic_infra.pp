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
# [*logging*]
#   Optional configurtaion hash for handling logfile forwarding into newrelic.
#
#   The below example will tail the mysql slow query logfile and send it's content
#   into new relic
#
#   Hiera config example:
#   ---
#   profiles::newrelic_infra::logging:
#     'mysql-slow-query-log':
#       ensure: 'present'
#       configfile: |
#         logs:
#           - name: "mysql-slow-query-log"
#             file: /var/log/mysql/slow-query.log
#             attributes:
#               logtype: mysql-slow-query-log
#
# [*integrations*]
#   Optional configuration hash for an integration.
#   If undefined, only basic system metrics will be monitored by the
#   newrelic-infra agent.
#
#   Hiera config example:
#   ---
#   profiles::newrelic_infra::integrations:
#     'nri-mysql':
#       ensure: 'present'
#
# [*integration_configfiles*]
#   When $integrations are defined, $integration_configfiles are required to configure
#   the integration.
#   two types of configfile exist:
#   'integration_config' takes care of the config for the service you are monitoring
#   'loggin_config' forwards content of a local logfile into NewRelic
#
#   Hiera config example:
#   ---
#   profiles::newrelic_infra::integration_configfiles:
#     'nri-mysql':
#       integration_config:
#         ensure: 'present'
#         configfile: |
#           integrations:
#             - name: nri-mysql
#               env:
#                 HOSTNAME: localhost
#                 PORT: 3306
#                 USERNAME: newrelic
#                 PASSWORD: <YOUR_SELECTED_PASSWORD>
#                 REMOTE_MONITORING: true
#               interval: 30s
#               labels:
#                 env: production
#                 role: write-replica
#               inventory_source: config/mysql
#       logging_config:
#         ensure: 'present'
#         configfile: |
#           logs:
#             - name: "mysqllog"
#               file: /var/log/mysql/error.log
#               attributes:
#                 logtype: mysql-error
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
  String                  $license_key              = lookup('data::newrelic::license_key', Optional[String], 'first', undef),
  Boolean                 $manage_repo              = false,
  Optional[Variant[Hash]] $logging                  = undef,
  Optional[Variant[Hash]] $integrations             = undef,
  Optional[Variant[Hash]] $integration_configfiles  = undef
) {

  realize Apt::Source['newrelic-infra']

  class { 'newrelic_infra::agent':
    ensure            => 'latest',
    license_key       => $license_key,
    manage_repo       => $manage_repo,
    custom_attributes => {
      environment => "$::environment"
    }
  }

  if $logging {
    $logging.each |$key,$value| {
      if $value['ensure'] == "present" {
        file { "${key}.yaml":
          ensure  => file,
          path    => "/etc/newrelic-infra/logging.d/${key}.yaml",
          content => $value['configfile'],
          notify  => Service['newrelic-infra']
        }
      }
      else {
        file { "${key}.yaml":
          ensure  => absent,
          path    => "/etc/newrelic-infra/logging.d/${key}.yaml",
          notify  => Service['newrelic-infra']
        }
      }
    }
  }

  if $integrations {
    class { 'newrelic_infra::integrations':
      integrations => $integrations
    }

    if $integration_configfiles {
      $integration_configfiles.each |$key,$value| {
        if $value['integration_config'] {
          if $value['integration_config']['ensure'] == "present" {
            file { "${key}-config.yaml":
              ensure  => file,
              path    => "/etc/newrelic-infra/integrations.d/${key}-config.yaml",
              content => $value['integration_config']['configfile'],
              notify  => Service['newrelic-infra']
            }
          }
          else {
            file { "${key}-config.yaml":
              ensure  => absent,
              path    => "/etc/newrelic-infra/integrations.d/${key}-config.yaml",
              notify  => Service['newrelic-infra']
            }
          }
        }

        if $value['logging_config'] {
          if $value['logging_config']['ensure'] == "present" {
            file { "${key}-log.yaml":
              ensure  => file,
              path    => "/etc/newrelic-infra/logging.d/${key}-log.yaml",
              content => $value['logging_config']['configfile'],
              notify  => Service['newrelic-infra']
            }
          }
          else {
            file { "${key}-log.yaml":
              ensure  => absent,
              path    => "/etc/newrelic-infra/logging.d/${key}-log.yaml",
              notify  => Service['newrelic-infra']
            }
          }
        }
      }
    }
  }
}
