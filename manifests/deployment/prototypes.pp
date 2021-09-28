class profiles::deployment::prototypes (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  include ::profiles::apt::keys

  apt::source { 'publiq-prototypes':
    location => 'https://apt.publiq.be/prototypes-production',
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'publiq-prototypes': }

  package { 'prototypes-publiq':
    ensure  => $version,
    require => Profiles::Apt::Update['publiq-prototypes']
  }

  profiles::deployment::versions { $title:
    project         => 'prototypes',
    packages        => 'prototypes-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url
  }
}
