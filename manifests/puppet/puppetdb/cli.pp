define profiles::puppet::puppetdb::cli (
  Optional[String]                         $certificate_name = undef,
  Optional[Variant[String, Array[String]]] $server_urls      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) {

  include ::profiles

  unless $server_urls {
    fail("Defined resource type Profiles::Puppet::Pupppetdb::Cli[${title}] expects a value for parameter 'server_urls'")
  }

  realize Apt::Source['publiq-tools']
  realize Package['rubygem-puppetdb-cli']

  profiles::puppet::puppetdb::cli::config { $title:
    certificate_name => $certificate_name,
    server_urls      => $server_urls
  }
}
