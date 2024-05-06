class profiles::puppet::puppetdb::certificate (
  String $certname
) inherits ::profiles {

  $default_file_attributes = {
                               owner => 'puppetdb',
                               group => 'puppetdb'
                             }

  realize Group['puppetdb']
  realize User['puppetdb']

  if !($certname == $facts['networking']['fqdn']) {
    puppet_certificate { $certname:
      ensure      => 'present',
      waitforcert =>  60
    }

    Puppet_certificate[$certname] -> File['puppetdb private_key']
    Puppet_certificate[$certname] -> File['puppetdb certificate']
  }

  file { 'puppetdb confdir':
    ensure  => 'directory',
    path    => '/etc/puppetlabs/puppetdb',
    mode    => '0750',
    require => [Group['puppetdb'], User['puppetdb']],
    *       => $default_file_attributes
  }

  file { 'puppetdb ssldir':
    ensure  => 'directory',
    path    => '/etc/puppetlabs/puppetdb/ssl',
    mode    => '0700',
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb confdir']],
    *       => $default_file_attributes
  }

  file { 'puppetdb cacert':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
    mode    => '0600',
    source  => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir']],
    *       => $default_file_attributes
  }

  file { 'puppetdb certificate':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppetdb/ssl/public.pem',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir']],
    *       => $default_file_attributes
  }

  file { 'puppetdb private_key':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppetdb/ssl/private.pem',
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => [Group['puppetdb'], User['puppetdb'], File['puppetdb ssldir']],
    *       => $default_file_attributes
  }
}
