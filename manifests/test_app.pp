class profiles::test_app (
  String                        $servername,
  Variant[String,Array[String]] $serveraliases   = [],
  Boolean                       $deployment      = true,
  String                        $display_message = 'nothing to see here'
) inherits ::profiles {

  $basedir = '/var/www/test-app'

  realize Group['www-data']
  realize User['www-data']

  include ::profiles::apache

  file { $basedir:
    ensure  => 'directory',
    owner   => 'www-data',
    group   => 'www-data',
    require => [Group['www-data'], User['www-data'], Class['profiles::apache']]
  }

  # Create index.html from template
  file { "${basedir}/index.html":
    ensure  => 'file',
    content => template('profiles/test_app/index.html.erb'),
    owner   => 'www-data',
    group   => 'www-data',
    require => File[$basedir]
  }

  if $deployment {
    include profiles::test_app::deployment
  }

  profiles::apache::vhost::basic { "http://${servername}":
    documentroot  => $basedir,
    serveraliases => $serveraliases,
    directories   => {
                       path     => $basedir,
                       provider => 'directory',
                       options  => ['Indexes', 'FollowSymLinks'],
                       headers  => [
                                     'set Cache-Control "max-age=300, public"'
                                   ]
                     }
  }
}
