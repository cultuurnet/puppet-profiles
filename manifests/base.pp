class profiles::base {

  contain ::profiles

  include ::profiles::groups
  include ::profiles::packages
  include ::profiles::repositories
  include ::profiles::users

  Shellvar {
    target  => '/etc/environment',
    require => [ Package['augeas-tools'], Package['ruby-augeas']]
  }

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Package['augeas-tools']
  realize Package['ruby-augeas']

  if $facts['ec2_metadata'] {
    $admin_user = 'ubuntu'
    realize Package['awscli']
  } else {
    $admin_user= 'vagrant'
    realize Package['ca-certificates-publiq']
  }

  realize Group[$admin_user]
  realize User[$admin_user]

  class { '::profiles::sudo':
    admin_user => $admin_user
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
    value    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/puppetlabs/bin'
  }

  shellvar { 'system RUBYLIB':
    ensure   => 'present',
    variable => 'RUBYLIB',
    value    => '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby'
  }
}
