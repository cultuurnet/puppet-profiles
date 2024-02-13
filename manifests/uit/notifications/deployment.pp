class profiles::uit::notifications::deployment (
  String           $config_source,
  String           $aws_access_key_id,
  String           $aws_secret_access_key,
  String           $version               = 'latest',
  String           $repository            = 'uit-notifications',
  Optional[String] $puppetdb_url          = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-notifications'

  realize Apt::Source[$repository]

  include profiles::nodejs

  package { 'uit-notifications':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source[$repository]
  }

  file { 'uit-notifications-config':
    ensure  => 'file',
    path    => "${basedir}/packages/notifications/env.yml",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => Package['uit-notifications']
  }

  exec { 'uit-notifications-deploy':
    command     => "yarn notifications deploy --cwd ${basedir}",
    cwd         => $basedir,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', $basedir],
    environment => ["AWS_ACCESS_KEY_ID=${aws_access_key_id}", "AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}"],
    logoutput   => true,
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [Package['uit-notifications'], File['uit-notifications-config']],
    require     => Class['profiles::nodejs']
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
