class profiles::deployment::prototypes (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  realize Apt::Source['publiq-prototypes']

  package { 'prototypes-publiq':
    ensure  => $version,
    require => Apt::Source['publiq-prototypes']
  }

  profiles::deployment::versions { $title:
    project         => 'prototypes',
    packages        => 'prototypes-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url
  }
}
