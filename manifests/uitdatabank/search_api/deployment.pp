class profiles::uitdatabank::search_api::deployment (
  String           $version        = 'latest',
  String           $repository     = 'uitdatabank-search-api',
  Boolean          $data_migration = false,
  String           $basedir        = '/var/www/udb3-search-service',
  Optional[String] $puppetdb_url   = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  realize Apt::Source[$repository]

  package { 'uitdatabank-search-api':
    ensure  => $version,
    notify  => [Service['uitdatabank-search-api'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  if $data_migration {
    Package['uitdatabank-search-api'] ~> Class['profiles::uitdatabank::search_api::data_migration']
  }

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-api':
    command   => 'udb3-consume-api',
    basedir   => $basedir,
    subscribe => Package['uitdatabank-search-api']
  }

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-cli':
    command   => 'udb3-consume-cli',
    basedir   => $basedir,
    subscribe => Package['uitdatabank-search-api']
  }

  profiles::uitdatabank::search_api::listener { 'uitdatabank-consume-related':
    command   => 'udb3-consume-related',
    basedir   => $basedir,
    subscribe => Package['uitdatabank-search-api']
  }

  profiles::php::fpm_service_alias { 'uitdatabank-search-api': }

  service { 'uitdatabank-search-api':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uitdatabank-search-api',
    require    => Profiles::Php::Fpm_service_alias['uitdatabank-search-api'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
