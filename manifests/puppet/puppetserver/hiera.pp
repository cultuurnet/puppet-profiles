class profiles::puppet::puppetserver::hiera (
  Boolean                   $eyaml                 = false,
  Hash                      $gpg_key               = {},
  Variant[Hash,Array[Hash]] $lookup_hierarchy      = [
                                                       { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                                       { 'name' => 'Common data', 'path' => 'common.yaml' }
                                                     ],
  Boolean                   $terraform_integration = false,
  Boolean                   $vault_integration     = false,
  Optional[String]          $vault_address         = undef,
  Hash                      $vault_mounts          = {}
) inherits ::profiles {

  if $vault_integration {
    if (!$vault_address or empty($vault_mounts)) {
      fail("Class Profiles::Puppet::Puppetserver::Hiera expects a non-empty value for parameters 'vault_address' and 'vault_mounts' when Vault integration is enabled")
    }
  }

  $terraform_lookup_hierarchy = $terraform_integration ? {
                                  true  => [
                                             { 'name' => 'Terraform per-node data', 'glob' => 'terraform/%{::trusted.certname}/*.yaml' },
                                             { 'name' => 'Terraform common data', 'path' => 'terraform/common.yaml' }
                                           ],
                                  false => []
                                }
  $vault_lookup_hierarchy     = $vault_integration ? {
                                  true  => [ {
                                             'name'       => 'Vault data',
                                             'lookup_key' => 'hiera_vault',
                                             'options'    => {
                                                               'confine_to_keys' => ['^vault:.*'],
                                                               'strip_from_keys' => ['vault:'],
                                                               'address'         => $vault_address,
                                                               'ssl_verify'      => true,
                                                               'ssl_ca_cert'     => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
                                                               'authentication'  => {
                                                                                      'method' => 'tls_certificate',
                                                                                      'config' => { 'certname' => $trusted['certname'] }
                                                                                    },
                                                               'mounts'          => $vault_mounts
                                                             }
                                           } ],
                                  false => []
                                }

  if $eyaml {
    if empty($gpg_key) {
      fail("Class Profiles::Puppet::Puppetserver::Hiera expects a non-empty value for parameter 'gpg_key' when eyaml is enabled")
    }

    $package_ensure = 'installed'
    $hierarchy      = $terraform_lookup_hierarchy + $vault_lookup_hierarchy + flatten([$lookup_hierarchy]).map |Hash $lookup| { $lookup + { 'lookup_key' => 'eyaml_lookup_key', 'options' => { 'gpg_gnupghome' => '/opt/puppetlabs/server/data/puppetserver/.gnupg' } } }

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
    $hierarchy      = $terraform_lookup_hierarchy + $vault_lookup_hierarchy + flatten([$lookup_hierarchy])

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
      provider => 'puppetserver_gem'
    }
  }

  class { 'hiera':
    hiera_version      => '5',
    hiera_yaml         => '/etc/puppetlabs/code/hiera.yaml',
    puppet_conf_manage => false,
    master_service     => 'puppetserver',
    datadir            => '/etc/puppetlabs/code/data',
    hiera5_defaults    => { 'datadir' => 'data', 'data_hash' => 'yaml_data' },
    hierarchy          => $hierarchy
  }
}
