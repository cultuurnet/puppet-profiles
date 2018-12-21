class profiles::base {

  contain ::profiles
  contain ::profiles::repositories
  contain ::profiles::packages

  realize Apt::Source['cultuurnet-tools']

  shellvar { 'PATH':
    ensure => 'present',
    target => '/etc/environment',
    value  => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin'
  }

  shellvar { 'RUBYLIB':
    ensure => 'present',
    target => '/etc/environment',
    value  => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
  }
}
