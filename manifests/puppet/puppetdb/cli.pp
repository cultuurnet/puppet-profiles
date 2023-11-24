class profiles::puppet::puppetdb::cli (
  Variant[String, Array[String]] $server_urls,
  Variant[String, Array[String]] $users          = 'root',
  Optional[String]               $certificate    = undef,
  Optional[String]               $private_key    = undef,
  Optional[String]               $ca_certificate = undef
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'rubygem-puppetdb-cli':
    require => Apt::Source['publiq-tools']
  }

  [$users].flatten.each |$user| {
    profiles::puppet::puppetdb::cli::config { $user:
      server_urls    => $server_urls,
      certificate    => $certificate,
      private_key    => $private_key,
      ca_certificate => $ca_certificate
    }
  }
}
