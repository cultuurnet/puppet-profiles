class profiles::deployment::uit::cms (
  String           $settings_source,
  String           $hostnames_source,
  String           $drush_config_source,
  String           $version              = 'latest',
  Optional[String] $database_version     = undef,
  Optional[String] $files_version        = undef,
  Optional[String] $puppetdb_url         = undef
) inherits ::profiles {

  $basedir = '/var/www/uit-cms'

  realize Apt::Source['uit-cms']

  package { 'uit-cms':
    ensure  => $version,
    notify  => Profiles::Deployment::Versions[$title],
    require => Apt::Source['uit-cms']
  }

  file { 'hostnames.txt':
    ensure => 'file',
    path   => '/var/www/uit-cms/hostnames.txt',
    source => $hostnames_source
  }

  if $database_version {
    package { 'uit-cms-database':
      ensure => $database_version,
      notify => [
                  Exec['uit-cms-db-install'],
                  Exec['uit-cms-cache-rebuild pre'],
                  Exec['uit-cms-updatedb'],
                  Exec['uit-cms-config-import'],
                  Exec['uit-cms-cache-rebuild post']
                ]
    }

    exec { 'uit-cms-db-install':
      command     => 'drush sql:cli < /data/uit-cms/database/db.sql',
      cwd         => $basedir,
      path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
      onlyif      => 'test 0 -eq $(vendor/bin/drush sql-query "show tables" | sed -e "/^$/d" | wc -l)',
      environment => [ 'HOME=/'],
      user        => 'www-data',
      refreshonly => true,
      subscribe   => [ Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']],
      before      => Exec['uit-cms-cache-rebuild pre']
    }
  }

  if $files_version {
    package { 'uit-cms-files':
      ensure  => $files_version
    }

    file { "${basedir}/web/sites/default/files":
      ensure  => 'directory',
      source  => '/data/uit-cms/files',
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      require => [ Package['uit-cms'], Package['uit-cms-files']]
    }
  } else {
    file { "${basedir}/web/sites/default/files":
      ensure  => 'directory',
      owner   => 'www-data',
      group   => 'www-data',
      require => Package['uit-cms']
    }
  }

  file { 'uit-cms-settings':
    ensure  => 'file',
    path    => "${basedir}/web/sites/default/settings.private.php",
    owner   => 'www-data',
    group   => 'www-data',
    source  => $settings_source,
    require => Package['uit-cms']
  }

  file { 'uit-cms-drush-config':
    ensure  => 'file',
    path    => "${basedir}/drush/drush.yml",
    source  => $drush_config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => Package['uit-cms']
  }

  exec { 'uit-cms-cache-rebuild pre':
    command     => 'drush cache:rebuild',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']]
  }

  exec { 'uit-cms-updatedb':
    command     => 'drush updatedb -y',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-cache-rebuild pre']
  }

  exec { 'uit-cms-config-import':
    command     => 'drush config:import -y',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-updatedb']
  }

  exec { 'uit-cms-cache-rebuild post':
    command     => 'drush cache:rebuild',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-config-import']
  }

  cron { 'uit-cms-core-cron':
    command     => "${basedir}/vendor/bin/drush -q core:cron",
    environment => [ 'MAILTO=infra@publiq.be' ],
    require     => Exec['uit-cms-cache-rebuild post'],
    user        => 'www-data',
    hour        => '*',
    minute      => [ '0', '30']
  }

  cron { 'uit-cms-curator-sync':
    command     => "${basedir}/vendor/bin/drush -q queue-run curator_sync",
    environment => [ 'MAILTO=infra@publiq.be' ],
    require     => Exec['uit-cms-cache-rebuild post'],
    user        => 'www-data',
    hour        => '*',
    minute      => '*'
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }
}
