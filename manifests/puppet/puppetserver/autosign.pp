class profiles::puppet::puppetserver::autosign (
  Variant[String, Array[String]] $trusted_amis = []
) inherits ::profiles {

  realize Group['puppet']
  realize User['puppet']

  file { 'puppetserver autosign':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppet/autosign',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0750',
    content => template('profiles/puppet/puppetserver/autosign.erb'),
    require => [Group['puppet'], User['puppet']]
  }

  package { 'aws-sdk-ec2':
    ensure   => 'installed',
    provider => 'puppetserver_gem'
  }
}
