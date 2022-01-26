class profiles::base inherits ::profiles {

  include ::profiles::groups
  include ::profiles::apt::updates
  include ::profiles::users
  include ::profiles::packages

  Shellvar {
    target  => '/etc/environment'
  }

  realize Profiles::Apt::Update['cultuurnet-tools']
  realize Package['ca-certificates-publiq']
  realize Package['policykit-1']

  if $facts['ec2_metadata'] {
    $admin_user = 'ubuntu'
    realize Package['awscli']
  } else {
    $admin_user= 'vagrant'
  }

  realize Group[$admin_user]
  realize User[$admin_user]

  class { '::profiles::sudo':
    admin_user => $admin_user
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
