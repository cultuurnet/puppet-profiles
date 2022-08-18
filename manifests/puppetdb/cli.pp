class profiles::puppetdb::cli(
  Variant[String, Array[String]] $server_urls,
  Variant[String, Array[String]] $users       = 'root',
  Optional[String]               $certificate = undef,
  Optional[String]               $private_key = undef

) inherits ::profiles {

  case $::operatingsystemrelease {
    '14.04', '16.04': {
      # original apt.uitdatabank.be repo
      $apt_repo = "cultuurnet-tools"
    }
    '18.04': {
      # new apt.publiq.be repo
      $apt_repo = "publiq-tools"
    }
    default: {
      fail("ERROR: No tools apt repository available for OS ${::operatingsystem}")
    }
  }

  realize Apt::Source[$apt_repo]

  package { 'rubygem-puppetdb-cli':
    require => Apt::Source[$apt_repo]
  }

  [$users].flatten.each |$user| {
    profiles::puppetdb::cli::config { $user:
      server_urls => $server_urls,
      certificate => $certificate,
      private_key => $private_key
    }
  }
}
