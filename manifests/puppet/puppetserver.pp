class profiles::puppet::puppetserver (
  String                                   $version               = 'installed',
  Optional[Variant[String, Array[String]]] $dns_alt_names         = undef,
  Boolean                                  $autosign              = false,
  Variant[String, Array[String]]           $trusted_amis          = [],
  Variant[String, Array[String]]           $trusted_certnames     = [],
  Boolean                                  $eyaml                 = false,
  Hash                                     $eyaml_gpg_key         = {},
  Variant[Hash,Array[Hash]]                $lookup_hierarchy      = [
                                                                      { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                                                      { 'name' => 'Common data', 'path' => 'common.yaml' }
                                                                    ],
  Boolean                                  $terraform_integration = false,
  Optional[String]                         $terraform_bucketpath  = undef,
  Optional[Stdlib::Httpurl]                $puppetdb_url          = undef,
  Optional[String]                         $puppetdb_version      = undef,
  Optional[String]                         $initial_heap_size     = undef,
  Optional[String]                         $maximum_heap_size     = undef,
  Enum['running', 'stopped']               $service_status        = 'running'

) inherits ::profiles {

  if ($autosign and !empty($trusted_amis) and !empty($trusted_certnames)) {
    fail("Class Profiles::Puppet::Puppetserver expects either a value for parameter 'trusted_amis' or 'trusted_certnames' when autosigning")
  }

  $default_ini_setting_attributes = {
                                      path    => '/etc/puppetlabs/puppet/puppet.conf',
                                      section => 'server'
                                    }

  include profiles::firewall::rules

  realize Firewall['300 accept puppetserver HTTPS traffic']

  ini_setting { 'puppetserver ca_server':
    ensure  => 'present',
    setting => 'ca_server',
    value   => $facts['networking']['fqdn'],
    before  => Class['profiles::puppet::puppetserver::install'],
    notify  => Class['profiles::puppet::puppetserver::service'],
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'puppetserver environmentpath':
    ensure  => 'present',
    setting => 'environmentpath',
    value   => '$codedir/environments',
    notify  => Class['profiles::puppet::puppetserver::service'],
    *       => $default_ini_setting_attributes
  }

  ini_setting { 'puppetserver environment_timeout':
    ensure  => 'present',
    setting => 'environment_timeout',
    value   => 'unlimited',
    notify  => Class['profiles::puppet::puppetserver::service'],
    *       => $default_ini_setting_attributes
  }

  puppet_authorization::rule { 'puppetserver environment cache':
    ensure               => 'present',
    match_request_path   => '/puppet-admin-api/v1/environment-cache',
    match_request_type   => 'path',
    match_request_method => 'delete',
    allow                => '*',
    sort_order           => 200,
    path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify               => Class['profiles::puppet::puppetserver::service']
  }

  if $dns_alt_names {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'present',
      setting => 'dns_alt_names',
      value   => [$dns_alt_names].flatten.join(','),
      before  => Class['profiles::puppet::puppetserver::install'],
      *       => $default_ini_setting_attributes
    }
  } else {
    ini_setting { 'puppetserver dns_alt_names':
      ensure  => 'absent',
      setting => 'dns_alt_names',
      before  => Class['profiles::puppet::puppetserver::install'],
      *       => $default_ini_setting_attributes
    }
  }

  class { 'profiles::puppet::puppetserver::autosign':
    autosign          => $autosign,
    trusted_amis      => $trusted_amis,
    trusted_certnames => $trusted_certnames,
    notify            => Class['profiles::puppet::puppetserver::service']
  }

  class { 'profiles::puppet::puppetserver::hiera':
    eyaml                 => $eyaml,
    gpg_key               => $eyaml_gpg_key,
    lookup_hierarchy      => $lookup_hierarchy,
    terraform_integration => $terraform_integration,
    require               => Class['profiles::puppet::puppetserver::install'],
    notify                => Class['profiles::puppet::puppetserver::service']
  }

  if $terraform_integration {
    class { 'profiles::puppet::puppetserver::terraform':
      bucketpath => $terraform_bucketpath,
      require    => Class['profiles::puppet::puppetserver::hiera'],
      notify     => Class['profiles::puppet::puppetserver::service']
    }
  }

  class { 'profiles::puppet::puppetserver::puppetdb':
    url     => $puppetdb_url,
    version => $puppetdb_version,
    notify  => Class['profiles::puppet::puppetserver::service']
  }

  class { 'profiles::puppet::puppetserver::install':
    version => $version,
    notify  => Class['profiles::puppet::puppetserver::service']
  }

  # Fix ownership of dropsonde directory, to stop the permission errors in puppetserver.log
  file { 'puppetserver dropsonde directory':
    owner   => 'puppet',
    path    => '/opt/puppetlabs/server/data/puppetserver/dropsonde',
    group   => 'puppet',
    require => [Group['puppet'], User['puppet'], Class['profiles::puppet::puppetserver::install']],
    notify  => Class['profiles::puppet::puppetserver::service']
  }

  hocon_setting { 'puppetserver dropsonde':
    ensure  => 'present',
    path    => '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf',
    setting => 'dropsonde.enabled',
    type    => 'boolean',
    value   => false,
    require => Class['profiles::puppet::puppetserver::install'],
    notify  => Class['profiles::puppet::puppetserver::service']
  }

  if $initial_heap_size {
    augeas { 'puppetserver_initial_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xms.*')] '-Xms${initial_heap_size}'",
      require => Class['profiles::puppet::puppetserver::install'],
      notify  => Class['profiles::puppet::puppetserver::service']
    }
  }

  if $maximum_heap_size {
    augeas { 'puppetserver_maximum_heap_size':
      lens    => 'Shellvars_list.lns',
      incl    => '/etc/default/puppetserver',
      context => '/files/etc/default/puppetserver/JAVA_ARGS',
      changes => "set value[. =~ regexp('-Xmx.*')] '-Xmx${maximum_heap_size}'",
      require => Class['profiles::puppet::puppetserver::install'],
      notify  => Class['profiles::puppet::puppetserver::service']
    }
  }

  class { 'profiles::puppet::puppetserver::service':
    status => $service_status
  }
}
