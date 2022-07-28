# Hiera config example:
#
# profiles::kibana::ensure: '8.3.2'
# profiles::kibana::config:
#   server.port: '8080'
#   server.publicBaseUrl: 'http://kibanadev.publiq.be'
#   elasticsearch.hosts:
#     - 'http://localhost:9200'
# profiles::kibana::reverse_proxy:
#   enabled: true
#   service_address: '127.0.0.1'
#   service_fqdn: 'kibanadev.publiq.be'

class profiles::kibana (
  String $ensure                   = 'latest',
  Optional[Hash] $config           = { 'server.port' => '8080' },
  Boolean $manage_repo             = false,
  Boolean $oss                     = false,
  Optional[String] $package_source = undef,
  String $status                   = 'enabled',
  Optional[Hash] $reverse_proxy    = {},
  String $reponame                 = 'elastic-8.x'
) inherits ::profiles {

  realize Apt::Source[$reponame]

  class { '::kibana':
    ensure         => $ensure,
    config         => $config,
    manage_repo    => $manage_repo,
    oss            => $oss,
    package_source => $package_source,
    status         => $status
  }

  if $reverse_proxy {
    profiles::apache::vhost::reverse_proxy { "http://${reverse_proxy['service_fqdn']}":
      destination => "http://${reverse_proxy['service_address']}:${config['server.port']}/"
    }
  }

}
