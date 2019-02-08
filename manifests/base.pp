class profiles::base {

  contain ::profiles

  realize Apt::Source['cultuurnet-tools']
  realize Package['awscli']

  if $settings::storeconfigs {
    @@sshkey { $::ipaddress_eth0:
      type => 'rsa',
      key  => $::sshrsakey
    }
  }

  class { 'lvm':
    manage_pkg => true
  }

  file { 'data':
    ensure => 'directory',
    group  => 'root',
    mode   => '0755',
    owner  => 'root',
    path   => '/data'
  }

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
