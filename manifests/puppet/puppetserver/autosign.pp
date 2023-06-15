class profiles::puppet::puppetserver::autosign (
  Boolean                        $autosign          = false,
  Variant[String, Array[String]] $trusted_amis      = [],
  Variant[String, Array[String]] $trusted_certnames = []
) inherits ::profiles {

  if $autosign {
    if (!empty($trusted_amis) and !empty($trusted_certnames)) {
      fail("Class Profiles::Puppet::Puppetserver expects either a value for parameter 'trusted_amis' or 'trusted_certnames' when autosigning")
    }

    realize Group['puppet']
    realize User['puppet']

    if !empty($trusted_amis) {
      $autosign_ini_setting = '/etc/puppetlabs/puppet/autosign'

      file { 'puppetserver autosign':
        ensure  => 'file',
        path    => '/etc/puppetlabs/puppet/autosign',
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0750',
        content => template('profiles/puppet/puppetserver/autosign.erb'),
        require => [Group['puppet'], User['puppet']]
      }

      file { 'puppetserver autosign.conf':
        ensure  => 'absent',
        path    => '/etc/puppetlabs/puppet/autosign.conf'
      }

      package { 'aws-sdk-ec2':
        ensure   => 'installed',
        provider => 'puppet_gem'
      }
    } else {
      $autosign_ini_setting = true

      file { 'puppetserver autosign.conf':
        ensure  => 'file',
        path    => '/etc/puppetlabs/puppet/autosign.conf',
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0640',
        content => [$trusted_certnames].flatten.join("\n"),
        require => [Group['puppet'], User['puppet']]
      }

      file { 'puppetserver autosign':
        ensure  => 'absent',
        path    => '/etc/puppetlabs/puppet/autosign',
      }
    }
  } else {
    $autosign_ini_setting = false

    file { 'puppetserver autosign.conf':
      ensure  => 'absent',
      path    => '/etc/puppetlabs/puppet/autosign.conf'
    }

    file { 'puppetserver autosign':
      ensure  => 'absent',
      path    => '/etc/puppetlabs/puppet/autosign',
    }
  }

  ini_setting { 'puppetserver autosign':
    ensure  => 'present',
    setting => 'autosign',
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'server',
    value   => $autosign_ini_setting
  }
}
