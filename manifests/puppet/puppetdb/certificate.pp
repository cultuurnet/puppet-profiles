class profiles::puppet::puppetdb::certificate (
  String $certname
) inherits ::profiles {

  realize Group['puppetdb']
  realize User['puppetdb']

  puppet_certificate { $certname:
    ensure      => 'present',
    waitforcert =>  60
  }

  file { 'puppetdb confdir':
    ensure  => 'directory',
    path    => '/etc/puppetlabs/puppetdb',
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0750',
    require => [Group['puppetdb'], User['puppetdb']]
  }

  file { 'puppetdb ssldir':
    ensure  => 'directory',
    path    => '/etc/puppetlabs/puppetdb/ssl',
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0700',
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb confdir']]
  }

  file { 'puppetdb cacert':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0600',
    source  => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir']]
  }

  file { 'puppetdb certificate':
    ensure  => 'file',
    path    => "/etc/puppetlabs/puppetdb/ssl/${certname}.pem",
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir'], Puppet_certificate[$certname]]
  }

  file { 'puppetdb private_key':
    ensure  => 'file',
    path    => "/etc/puppetlabs/puppetdb/ssl/${certname}.key",
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir'], Puppet_certificate[$certname]]
  }

  file { 'puppetdb default certificate':
    ensure  => 'absent',
    path    => '/etc/puppetlabs/puppetdb/ssl/public.pem',
    require => File['puppetdb ssldir']
  }

  file { 'puppetdb default private_key':
    ensure  => 'absent',
    path    => '/etc/puppetlabs/puppetdb/ssl/private.pem',
    require => File['puppetdb ssldir']
  }
}
