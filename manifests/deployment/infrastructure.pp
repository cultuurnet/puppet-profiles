class profiles::deployment::infrastructure (
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  contain ::profiles

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
    ensure  => $package_version,
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
