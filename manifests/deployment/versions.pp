define profiles::deployment::versions (
  Optional[String] $puppetdb_url    = undef
) {

  include ::profiles
  include ::profiles::deployment

  if $puppetdb_url {
    exec { "update facts due to deployment of ${title}":
      command     => "update_facts -p ${puppetdb_url}",
      path        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
      subscribe   => Class['::profiles::deployment'],
      refreshonly => true
    }
  }
}
