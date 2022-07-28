define profiles::deployment::versions (
  String                                    $project,
  Variant[ Optional[String], Array[String]] $packages        = undef,
  Optional[String]                          $puppetdb_url    = undef
) {

  include ::profiles
  include ::profiles::deployment

  if $packages {
    [$packages].flatten.each |$package| {
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
