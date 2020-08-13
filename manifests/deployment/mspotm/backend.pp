class profiles::deployment::mspotm::backend (
  String           $config_source,
  String           $package_version     = 'latest',
  Optional[String] $puppetdb_url        = undef
) {

  $basedir = '/var/www/mspotm-backend'

  contain ::profiles

  include ::profiles::deployment::mspotm

  realize Apt::Source['publiq-mspotm']
  realize Profiles::Apt::Update['publiq-mspotm']

  package { 'mspotm-backend':
    ensure  => $package_version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Profiles::Apt::Update['publiq-mspotm']
  }

  file { 'mspotm-backend-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['mspotm-backend']
  }

  profiles::deployment::versions { $title:
    project      => 'mspotm',
    packages     => 'mspotm-backend',
    puppetdb_url => $puppetdb_url
  }
}
