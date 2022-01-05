class profiles::puppetdb::cli(
  Variant[String, Array[String]] $server_urls,
  Variant[String, Array[String]] $users       = 'root',
  Optional[String]               $certificate = undef,
  Optional[String]               $private_key = undef

) inherits ::profiles {

  include ::profiles::apt::updates
  include ::profiles::groups
  include ::profiles::users

  realize Profiles::Apt::Update['cultuurnet-tools']

  package { 'rubygem-puppetdb-cli':
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  [$users].flatten.each |$user| {
    unless $user == 'root' {
      realize Group[$user]
      realize User[$user]

      User[$user] -> Profiles::Puppetdb::Cli::Config[$user]
    }

    profiles::puppetdb::cli::config { $user:
      server_urls => $server_urls,
      certificate => $certificate,
      private_key => $private_key
    }
  }
}
