define profiles::deployment::versions (
  String                                    $project,
  Variant[ Optional[String], Array[String]] $packages        = undef,
  String                                    $destination_dir = '/var/www',
  Optional[String]                          $puppetdb_url    = undef
) {

  contain ::profiles
  contain ::profiles::deployment

  include ::profiles::packages

  realize Package['jq']

  if $packages {
    any2array($packages).each |$package| {
      exec { "update versions.${project} file for package ${package}":
        command     => "facter -pj ${project}_version | jq '.[\"${project}_version\"]' > ${destination_dir}/versions.${project}",
        path        => [ '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
        require     => Package['jq'],
        refreshonly => true
      }

      exec { "update versions.${project}.${package} file for package ${package}":
        command     => "facter -pj ${project}_version.${package} | jq '.[\"${project}_version.${package}\"]' > ${destination_dir}/versions.${project}.${package}",
        path        => [ '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
        require     => Package['jq'],
        refreshonly => true
      }

      if $puppetdb_url {
        exec { "update_facts for ${package} package":
          command     => "update_facts -p ${puppetdb_url}",
          path        => [ '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
          subscribe   => Class['::profiles::deployment'],
          refreshonly => true
        }
      }
    }
  }
}
