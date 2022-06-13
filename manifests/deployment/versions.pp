define profiles::deployment::versions (
  String                                    $project,
  Variant[ Optional[String], Array[String]] $packages        = undef,
  String                                    $destination_dir = '/var/www',
  Optional[String]                          $puppetdb_url    = undef
) {

  include ::profiles
  include ::profiles::deployment

  realize Package['jq']

  if $packages {
    any2array($packages).each |$package| {
      exec { "update versions.${project} file for package ${package}":
        command     => "facter -pj ${project}_deployment_version | jq '.[\"${project}_deployment_version\"]' > ${destination_dir}/versions.${project}",
        path        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
        require     => Package['jq'],
        subscribe   => Package[$package],
        refreshonly => true
      }

      exec { "update versions.${project}.${package} file for package ${package}":
        command     => "facter -pj ${project}_deployment_version.${package} | jq '.[\"${project}_deployment_version.${package}\"]' > ${destination_dir}/versions.${project}.${package}",
        path        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
        require     => Package['jq'],
        subscribe   => Package[$package],
        refreshonly => true
      }

      if $puppetdb_url {
        exec { "update facts for package ${package}":
          command     => "update_facts -p ${puppetdb_url}",
          path        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
          subscribe   => [ Class['::profiles::deployment'], Package[$package] ],
          refreshonly => true
        }
      }
    }
  }
}
