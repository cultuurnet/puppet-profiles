class profiles::environment inherits ::profiles {

  Shellvar {
    target  => '/etc/environment'
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
