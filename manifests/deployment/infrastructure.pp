class profiles::deployment::infrastructure (
  String           $version      = 'latest',
  Optional[String] $puppetdb_url = undef
) inherits ::profiles {

  include ::profiles::apt::keys
  include ::profiles::puppetserver::cache_clear

  apt::source { 'publiq-infrastructure':
    location => 'https://apt.publiq.be/infrastructure-production',
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'publiq-infrastructure': }

  package { 'infrastructure-publiq':
    ensure  => $version,
    notify  => Class['profiles::puppetserver::cache_clear'],
    require => Profiles::Apt::Update['publiq-infrastructure']
  }

  profiles::deployment::versions { $title:
    project         => 'infrastructure',
    packages        => 'infrastructure-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppetserver::cache_clear']
  }
}
