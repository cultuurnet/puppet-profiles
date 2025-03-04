class profiles::uit::cms::deployment (
  String           $config_source,
  String           $drush_config_source,
  String           $version             = 'latest',
  String           $repository          = 'uit-cms',
  Optional[String] $puppetdb_url        = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/uit-cms'

  realize Group['www-data']
  realize User['www-data']

  realize Apt::Source[$repository]

  package { 'uit-cms':
    ensure  => $version,
    notify  => [Service['uit-cms'], Profiles::Deployment::Versions[$title]],
    require => Apt::Source[$repository]
  }

  file { 'uit-cms-settings':
    ensure  => 'file',
    path    => "${basedir}/web/sites/default/settings.private.php",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $config_source,
    require => [Group['www-data'], User['www-data'], Package['uit-cms']],
    notify  => Service['uit-cms']
  }

  file { 'uit-cms-drush-config':
    ensure  => 'file',
    path    => "${basedir}/drush/drush.yml",
    source  => $drush_config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Package['uit-cms']],
    notify  => Service['uit-cms']
  }

  exec { 'uit-cms-drush-deploy':
    command     => 'drush deploy -v -y',
    cwd         => $basedir,
    path        => ['/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => ['HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    logoutput   => 'on_failure',
    require     => User['www-data'],
    subscribe   => [Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']]
  }

  cron { 'uit-cms-core-cron':
    command     => "${basedir}/vendor/bin/drush -q core:cron",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'www-data',
    hour        => '*',
    minute      => ['0', '30'],
    require     => [User['www-data'], Exec['uit-cms-drush-deploy']]
  }

  cron { 'uit-cms-curator-sync':
    command     => "${basedir}/vendor/bin/drush -q queue-run curator_sync",
    environment => ['MAILTO=infra+cron@publiq.be'],
    user        => 'www-data',
    hour        => '*',
    minute      => '*',
    require     => [User['www-data'], Exec['uit-cms-drush-deploy']]
  }

  profiles::php::fpm_service_alias { 'uit-cms': }

  service { 'uit-cms':
    hasstatus  => true,
    hasrestart => true,
    restart    => '/usr/bin/systemctl reload uit-cms',
    require    => Profiles::Php::Fpm_service_alias['uit-cms'],
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
