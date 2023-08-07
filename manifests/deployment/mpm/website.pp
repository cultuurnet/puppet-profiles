class profiles::deployment::mpm::website (
  String $varnish_secret                    = undef,
  String $mysql_admin_user                  = 'admin',
  String $mysql_admin_password              = undef,
  String $mysql_host                        = undef,
  Hash $mysql_databases                     = undef,
  Optional[Variant[Hash]] $varnish_backends = undef,
  String $vhost                             = undef,
  String $repository                        = 'museumpas-website',
  $config_source,
  $maintenance_source,
  $version                                  = 'latest',
  $robots_source                            = undef,
  $noop_deploy                              = false,
  $puppetdb_url                             = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $basedir = '/var/www/museumpas'

  class { 'locales':
    default_locale  => 'en_US.UTF-8',
    locales         => ['nl_BE.UTF-8 UTF8', 'fr_BE.UTF-8 UTF8', 'nl_NL.UTF-8 UTF8', 'fr_FR.UTF-8 UTF8'],
  }

  include apache::mod::expires
  include apache::mod::headers
  include apache::mod::rewrite
  inclide apache::vhosts

  file { 'root_my_cnf':
    ensure  => 'file',
    path    => '/root/.my.cnf',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => template('profiles/mpm/my.cnf.erb'),
  }

  # Database gets created correctly
  # But issue with user creation
  # See: https://github.com/puppetlabs/puppetlabs-mysql/blob/v14.0.0/README.md?plain=1#L190
  #
  # $mysql_databases.each |$name,$properties| {
  #   mysql::db { $name:
  #     user     => $properties['user'],
  #     password => $properties['password'],
  #     host     => $properties['host'],
  #     require  => [File['root_my_cnf'],Package['mysql-client']]
  #   }
  # }

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
    command     => 'vendor/bin/composer run-script post-autoload-dump',
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
    command     => 'php artisan modelCache:clear',
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

  profiles::deployment::versions { $title:
    puppetdb_url => $puppetdb_url
  }

  Class['php'] -> Class['profiles::deployment::mpm::website']
}

