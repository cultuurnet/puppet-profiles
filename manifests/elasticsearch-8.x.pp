# Hiera example config:
#
# profiles::elasticsearch::version: '8.3.2'
# profiles::elasticsearch::config:
#   xpack.security.enabled: false
#   xpack.security.transport.ssl.enabled: false
#   xpack.security.http.ssl.enabled: false
# profiles::elasticsearch::plugins:
#   'x-pack':
#     ensure: present

class profiles::elasticsearch (
  String                  $api_host              = 'localhost',
  Integer[0,65535]        $api_port              = 9200,
  Optional[Hash]          $config                = {},
  Optional[Array[String]] $jvm_options           = undef,
  Boolean                 $manage_repo           = false,
  Boolean                 $restart_on_change     = true,
  Boolean                 $ssl                   = false,
  Boolean                 $validate_tls          = false,
  String                  $version               = 'latest',
  Optional[Hash]          $indices               = {},
  Optional[Hash]          $snapshot_repositories = {},
  Optional[Hash]          $scripts               = {},
  Optional[Hash]          $users                 = {},
  Optional[Hash]          $roles                 = {},
  Optional[Hash]          $pipelines             = {},
  Optional[Hash]          $plugins               = {},
  Optional[Hash]          $templates             = {}
) inherits ::profiles {

  case $version {
    /^8.*/:  {
      $reponame = "elastic-8.x"
    }
    default: {
      $reponame = "elasticsearch"
      contain ::profiles::java
    }
  }

  realize Apt::Source[$reponame]

  # TODO: parameterize this profile (version, ...)
  # TODO: add /data/backups/elasticsearch directory
  # TODO: add snapshot repositories and backup schedule (maybe in product profile)
  # TODO: unit tests
  # TODO: firewall rules

  file { '/data/elasticsearch':
    ensure => 'directory',
    before => Class['elasticsearch']
  }

  # sysctl { 'vm.max_map_count':
  #   value  => '262144',
  #   before => Class['elasticsearch']
  # }

  case $version {
    /^8.*/:  {
      class { '::elasticsearch':
        version           => $version,
        config            => $config,
        api_host          => $api_host,
        api_port          => $api_port,
        jvm_options       => $jvm_options,
        manage_repo       => $manage_repo,
        restart_on_change => $restart_on_change,
        ssl               => $ssl,
        validate_tls      => $validate_tls,
        require           => [Apt::Source[$reponame]]
      }

      create_resources('elasticsearch::index', $indices)
      create_resources('elasticsearch::snapshot_repository', $snapshot_repositories)
      create_resources('elasticsearch::script', $scripts)
      create_resources('elasticsearch::user', $users)
      create_resources('elasticsearch::role', $roles)
      create_resources('elasticsearch::pipeline', $pipelines)
      create_resources('elasticsearch::plugin', $plugins)
      create_resources('elasticsearch::template', $templates)
    }
    default: {
      class { '::elasticsearch':
        version           => $version,
        manage_repo       => false,
        api_timeout       => 30,
        restart_on_change => true,
        instances         => {},
        require           => [Apt::Source[$reponame], Class['::profiles::java']]
      }
    }
  }
}
