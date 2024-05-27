class profiles::puppet::puppetboard::certificate (
  String $certname,
  String $basedir  = '/var/www/puppetboard'
) inherits ::profiles {

  $default_file_attributes = {
                               owner => 'www-data',
                               group => 'www-data'
                             }

  realize Group['www-data']
  realize User['www-data']

  if !($certname == $facts['networking']['fqdn']) {
    puppet_certificate { $certname:
      ensure               => 'present',
      waitforcert          => 60,
      renewal_grace_period => 5,
      clean                => true
    }

    Puppet_certificate[$certname] -> File['puppetboard private_key']
    Puppet_certificate[$certname] -> File['puppetboard certificate']
  }

  file { 'puppetboard basedir':
    ensure  => 'directory',
    path    => $basedir,
    mode    => '0700',
    require => [Group['www-data'], User['www-data']],
    *       => $default_file_attributes
  }

  file { 'puppetboard ssldir':
    ensure  => 'directory',
    path    => "${basedir}/ssl",
    mode    => '0700',
    require => [Group['www-data'], User['www-data'], File['puppetboard basedir']],
    *       => $default_file_attributes
  }

  file { 'puppetboard certificate':
    ensure  => 'file',
    path    => "${basedir}/ssl/public.pem",
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => [Group['www-data'], User['www-data'], File['puppetboard ssldir']],
    *       => $default_file_attributes
  }

  file { 'puppetboard private_key':
    ensure  => 'file',
    path    => "${basedir}/ssl/private.pem",
    mode    => '0600',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => [Group['www-data'], User['www-data'], File['puppetboard ssldir']],
    *       => $default_file_attributes
  }
}
