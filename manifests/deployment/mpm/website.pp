class profiles::deployment::mpm::website (
  String $varnish_secret                     = undef,
  String $mysql_version                      = undef,
  String $mysql_admin_user                   = 'admin',
  String $mysql_admin_password               = undef,
  String $mysql_host                         = undef,
  Hash $mysql_databases                      = undef,
  Optional[Variant[Hash]] $varnish_backends  = undef,
  String $vhost                              = undef,
  String $repository                         = 'museumpas-website',
  Enum['running', 'stopped'] $service_status = 'running',
  Boolean $install_meilisearch               = true,
  $config_source,
  $maintenance_source,
  $version                                   = 'latest',
  $robots_source                             = undef,
  $noop_deploy                               = false,
  $puppetdb_url                              = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  class { 'locales':
    default_locale  => 'en_US.UTF8',
    locales         => ['nl_BE.UTF8 UTF8', 'fr_BE.UTF8 UTF8', 'nl_NL.UTF8 UTF8', 'fr_FR.UTF8 UTF8'],
  }

  include apache::mod::expires
  include apache::mod::headers
  include apache::mod::rewrite
  include apache::mod::proxy
  include apache::mod::proxy_fcgi
  include apache::vhosts
  include profiles::firewall::rules

  if $install_meilisearch {
    include profiles::meilisearch
  }

  realize Firewall['300 accept HTTP traffic']

  file { 'mysqld_version_ext_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "mysqld_version=$mysql_version"
  }

  file { 'root_my_cnf':
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/mpm/my.cnf.erb'),
    require  => [File['mysqld_version_ext_fact']]
  }

  $mysql_databases.each |$name,$properties| {
    mysql::db { $name:
      user     => $properties['user'],
      password => $properties['password'],
      host     => $properties['host'],
      require  => [File['root_my_cnf']]
    }
  }

  file { 'varnish-secret':
    ensure  => 'file',
    path    => "/etc/varnish/secret",
    content => $varnish_secret,
    owner   => 'varnish',
    group   => 'varnish',
    require => [Class['varnish']]
  }

  class { 'varnish::vcl':
    backends => {},
    require => [Class['varnish']]
  }
  create_resources('varnish::vcl::backend', $varnish_backends)

  realize Apt::Source[$repository]

  package { 'museumpas-website':
    ensure  => $version,
    require => Apt::Source[$repository],
    notify  => Profiles::Deployment::Versions[$title],
    noop    => $noop_deploy
  }

  file { 'museumpas-website-config':
    ensure  => 'file',
    path    => "${basedir}/.env",
    source  => $config_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => 'Package[museumpas-website]',
    noop    => $noop_deploy
  }

  file { 'museumpas-maintenance-pages':
    ensure  => 'directory',
    path    => "${basedir}/public/maintenance",
    recurse => true,
    source  => $maintenance_source,
    owner   => 'www-data',
    group   => 'www-data',
    require => 'Package[museumpas-website]',
    noop    => $noop_deploy
  }

  if $robots_source {
    file { 'museumpas-robots.txt':
      ensure  => 'file',
      path    => "${basedir}/public/robots.txt",
      source  => $robots_source,
      owner   => 'www-data',
      group   => 'www-data',
      require => 'Package[museumpas-website]',
      noop    => $noop_deploy
    }
  }

  exec { 'composer script post-autoload-dump':
    command     => '/usr/bin/composer run-script post-autoload-dump',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
    user        => 'www-data',
    environment => [ 'HOME=/tmp'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => File['museumpas-website-config'],
    noop        => $noop_deploy
  }

  exec { 'put museumpas in maintenance mode':
    command     => 'php artisan down',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['composer script post-autoload-dump']],
    noop        => $noop_deploy
  }

  exec { 'run museumpas database migrations':
    command     => 'php artisan migrate --force',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['put museumpas in maintenance mode'] ],
    noop        => $noop_deploy
  }

  exec { 'clear museumpas cache':
    command     => 'php artisan optimize:clear',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'] ],
    noop        => $noop_deploy
  }

  exec { 'clear museumpas model cache':
    command     => 'php artisan -q modelCache:clear',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'], Exec['clear museumpas cache'] ],
    noop        => $noop_deploy
  }

  exec { 'create storage link':
    command     => 'php artisan storage:link',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    logoutput   => true,
    unless      => "test -L ${basedir}/public/storage",
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['run museumpas database migrations'] ],
    noop        => $noop_deploy
  }

  exec { 'put museumpas in production mode':
    command     => 'php artisan up',
    cwd         => $basedir,
    path        => [ '/usr/local/bin', '/usr/bin', '/bin'],
    user        => 'www-data',
    environment => [ 'HOME=/'],
    logoutput   => true,
    subscribe   => Package['museumpas-website'],
    refreshonly => true,
    require     => [ File['museumpas-website-config'], Exec['create storage link'], Exec['clear museumpas model cache'] ],
    noop        => $noop_deploy
  }

  systemd::unit_file { 'museumpas-website-horizon.service':
    source  => 'puppet:///modules/profiles/deployment/mpm/museumpas-website-horizon.service',
    enable  => true,
    active  => true,
    require => Package['museumpas-website']
  }

  service { 'museumpas-website-horizon':
    ensure    => $service_status,
    hasstatus => true,
    enable    => $service_status ? {
                   'running' => true,
                   'stopped' => false
                 },
    require   => [Systemd::Unit_file['museumpas-website-horizon.service']]
  }

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }

  Class['php'] -> Class['profiles::deployment::mpm::website']
}

