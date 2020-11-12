class profiles::deployment::appconfig (
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  contain ::profiles

  include ::profiles::apt::keys
  include ::profiles::puppetserver::cache_clear

  apt::source { 'publiq-appconfig':
    location => 'https://apt.publiq.be/appconfig-production',
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt::keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'publiq-appconfig':
    require => Apt::Source['publiq-appconfig']
  }

  package { 'appconfig-publiq':
    ensure  => $package_version,
    notify  => Class['profiles::puppetserver::cache_clear'],
    require => Profiles::Apt::Update['publiq-appconfig']
  }

  profiles::deployment::versions { $title:
    project         => 'appconfig',
    packages        => 'appconfig-publiq',
    destination_dir => '/var/run',
    puppetdb_url    => $puppetdb_url,
    require         => Class['profiles::puppetserver::cache_clear']
  }
}
