class profiles::deployment::infrastructure (
  String           $package_version = 'latest',
  Optional[String] $puppetdb_url    = undef
) {

  contain ::profiles

  include ::profiles::apt_keys

  apt::source { 'publiq-infrastructure':
    location => 'http://apt.publiq.be/infrastructure-production',
    release  => $facts['lsbdistcodename'],
    repos    => 'main',
    require  => Class['profiles::apt_keys'],
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  profiles::apt::update { 'publiq-infrastructure':
    require => Apt::Source['publiq-infrastructure']
  }

  package { 'infrastructure-publiq':
    ensure  => $package_version,
    require => Profiles::Apt::Update['publiq-infrastructure']
  }

  exec { 'puppetserver_environment_cache_clear':
    command     => 'curl -i -k --fail -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    subscribe   => Package['infrastructure-publiq'],
    refreshonly => true
  }

  profiles::deployment::versions { $title:
    project      => 'infrastructure',
    packages     => 'infrastructure-publiq',
    puppetdb_url => $puppetdb_url,
    require      => Exec['puppetserver_environment_cache_clear']
  }
}
