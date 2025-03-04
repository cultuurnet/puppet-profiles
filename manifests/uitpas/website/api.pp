class profiles::uitpas::website::api (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases       = [],
  Boolean                        $deployment          = true
) inherits ::profiles {

  $basedir = '/var/www/uitpas-website-api'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data']]
  }

  profiles::apache::vhost::php_fpm { "http://${servername}":
    basedir              => $basedir,
    public_web_directory => 'public',
    aliases              => $serveraliases
  }

  if $deployment {
    include profiles::uitpas::website::api::deployment

    Class['profiles::uitpas::website::api::deployment'] -> Apache::Vhost["${servername}_80"]
  }
}
