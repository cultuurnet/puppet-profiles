class profiles::deployment::uit::cms (
  String           $settings_source,
  String           $drush_config_source,
  String           $package_version         = 'latest',
  String           $database_version        = 'latest',
  String           $files_version           = 'latest',
  Optional[String] $puppetdb_url            = undef
) {

  $basedir         = '/var/www/uit-cms'
  $database_source = '/data/uit-cms/database/db.sql'
  $files_source    = '/data/uit-cms/files'

  contain ::profiles

  include ::profiles::apt::repositories
  include ::profiles::deployment::uit

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']

  package { 'uit-cms':
    ensure => $package_version
  }

  package { 'uit-cms-database':
    ensure => $database_version
  }

  package { 'uit-cms-files':
    ensure  => $files_version
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

  file { "${basedir}/web/sites/default/files":
    ensure  => 'directory',
    source  => $files_source,
    owner   => 'www-data',
    group   => 'www-data',
    recurse => true,
    require => [ Package['uit-cms'], Package['uit-cms-files']]
  }

  exec { 'uit-cms-db-install':
    command     => "drush sql:cli < ${database_source}",
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    onlyif      => 'test 0 -eq $(vendor/bin/drush sql-query "show tables" | sed -e "/^$/d" | wc -l)',
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], Package['uit-cms-database'], File['uit-cms-settings'], File['uit-cms-drush-config']]
  }

  exec { 'uit-cms-cache-rebuild pre':
    command     => 'drush cache:rebuild',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], Package['uit-cms-database'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-db-install']
  }

  exec { 'uit-cms-updatedb':
    command     => 'drush updatedb -y',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], Package['uit-cms-database'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-cache-rebuild pre']
  }

  exec { 'uit-cms-config-import':
    command     => 'drush config:import -y',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], Package['uit-cms-database'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-updatedb']
  }

  exec { 'uit-cms-cache-rebuild post':
    command     => 'drush cache:rebuild',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', "${basedir}/vendor/bin"],
    environment => [ 'HOME=/'],
    user        => 'www-data',
    refreshonly => true,
    subscribe   => [ Package['uit-cms'], Package['uit-cms-database'], File['uit-cms-settings'], File['uit-cms-drush-config']],
    require     => Exec['uit-cms-config-import']
  }

  profiles::deployment::versions { $title:
    project      => 'uit',
    packages     => [ 'uit-cms', 'uit-cms-database', 'uit-cms-files'],
    puppetdb_url => $puppetdb_url
  }
}
