class profiles::base {

  contain ::profiles

  include ::profiles::groups
  include ::profiles::packages
  include ::profiles::repositories
  include ::profiles::users

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  if $facts['ec2_metadata'] {
    realize Package['awscli']
    realize Group['ubuntu']
    realize User['ubuntu']
  } else {
    realize Package['ca-certificates-publiq']
    realize Group['vagrant']
    realize User['vagrant']
  }

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

  shellvar { 'system PATH':
    ensure   => 'present',
    variable => 'PATH',
    target   => '/etc/environment',
    value    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin'
  }

  shellvar { 'system RUBYLIB':
    ensure   => 'present',
    variable => 'RUBYLIB',
    target   => '/etc/environment',
    value    => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
  }
}
