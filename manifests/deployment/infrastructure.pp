class profiles::deployment::infrastructure {

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

  package { 'publiq-infrastructure':
    ensure  => 'latest',
    require => Profiles::Apt::Update['publiq-infrastructure']
  }

  exec { 'puppetserver_environment_cache_clear':
    command     => 'curl -i -k --fail -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    subscribe   => Package['publiq-infrastructure'],
    refreshonly => true
  }
}
