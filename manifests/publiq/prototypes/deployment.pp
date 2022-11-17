class profiles::publiq::prototypes::deployment (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  realize Apt::Source['publiq-prototypes']

  package { 'publiq-prototypes':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['publiq-prototypes']
  }

  profiles::deployment::versions { $title:
    puppetdb_url    => $puppetdb_url
  }
}
