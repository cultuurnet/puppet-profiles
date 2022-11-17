class profiles::deployment::uit::notifications (
  String           $settings_source,
  String           $aws_access_key_id,
  String           $aws_secret_access_key,
  String           $version          = 'latest',
  Optional[String] $puppetdb_url     = undef
) inherits ::profiles {

  $basedir = '/var/www/uit-notifications'

  realize Apt::Source['uit-notifications']

  package { 'uit-notifications':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uit-notifications']
  }

  file { 'uit-notifications-settings':
    ensure  => 'file',
    path    => "${basedir}/packages/notifications/env.yml",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $settings_source,
    require => Package['uit-notifications']
  }

  exec { 'uit-notifications-deploy':
    command     => '/usr/bin/yarn notifications deploy',
    cwd         => $basedir,
    path        => [ "${basedir}", '/usr/local/bin', '/usr/bin', '/bin'],
    environment => [ "AWS_ACCESS_KEY_ID=${aws_access_key_id}", "AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}"],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-notifications'], File['uit-notifications-settings']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
