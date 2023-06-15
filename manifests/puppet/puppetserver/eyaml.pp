class profiles::puppet::puppetserver::eyaml (
  Boolean $enable  = false,
  Hash    $gpg_key = {}
) inherits ::profiles {

  if $enable {
    if empty($gpg_key) {
      fail("Class Profiles::Puppet::Puppetserver::Eyaml expects a non-empty value for parameter 'gpg_key' when eyaml is enabled")
    }

    $package_ensure = 'installed'

    realize Group['puppet']
    realize User['puppet']

    file { 'puppetserver eyaml configdir':
      ensure => 'directory',
      path   => '/opt/puppetlabs/server/data/puppetserver/.eyaml',
      owner  => 'puppet',
      group  => 'puppet'
    }

    file { 'puppetserver eyaml configuration':
      ensure => 'file',
      path   => '/opt/puppetlabs/server/data/puppetserver/.eyaml/config.yaml',
      owner  => 'puppet',
      group  => 'puppet',
      source => 'puppet:///modules/profiles/puppet/puppetserver/eyaml/config.yaml'
    }

    gnupg_key { $gpg_key['id']:
      ensure      => 'present',
      key_id      => $gpg_key['id'],
      user        => 'puppet',
      key_content => $gpg_key['content'],
      key_type    => 'private',
      require     => User['puppet']
    }

    Package['ruby_gpg'] -> Package['hiera-eyaml']
    Package['hiera-eyaml'] -> Package['hiera-eyaml-gpg']
  } else {
    $package_ensure = 'absent'

    file { 'puppetserver eyaml configdir':
      ensure => 'absent',
      path   => '/opt/puppetlabs/server/data/puppetserver/.eyaml',
      force  => true
    }

    file { 'puppetserver eyaml configuration':
      ensure => 'absent',
      path   => '/opt/puppetlabs/server/data/puppetserver/.eyaml/config.yaml'
    }

    Package['hiera-eyaml-gpg'] -> Package['hiera-eyaml']
    Package['hiera-eyaml'] -> Package['ruby_gpg']
  }

  ['ruby_gpg', 'hiera-eyaml', 'hiera-eyaml-gpg'].each |$package| {
    package { $package:
      ensure   => $package_ensure,
      provider => 'puppet_gem'
    }
  }
}
