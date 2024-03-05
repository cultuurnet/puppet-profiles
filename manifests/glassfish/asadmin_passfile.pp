class profiles::glassfish::asadmin_passfile (
  String $password        = 'adminadmin',
  String $master_password = 'changeit'
) inherits ::profiles {

  realize Group['glassfish']
  realize User['glassfish']

  file { 'asadmin_passfile':
    ensure  => 'file',
    path    => '/home/glassfish/asadmin.pass',
    owner   => 'glassfish',
    group   => 'glassfish',
    mode    => '0600',
    content => template('profiles/glassfish/asadmin_passfile.erb'),
    require => [Group['glassfish'], User['glassfish']]
  }
}
