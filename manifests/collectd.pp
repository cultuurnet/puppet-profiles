class profiles::collectd (
  Boolean          $enable        = true,
  Optional[String] $graphite_host = undef
) inherits ::profiles {

  if $enable {
    $service_enable = true
    $service_ensure = 'running'
  } else {
    $service_enable = false
    $service_ensure = 'stopped'
  }

  collectd::typesdb { '/etc/collectd/types.db':
    path   => '/etc/collectd/types.db'
  }

  class { '::collectd':
    manage_repo       => false,
    package_name      => 'collectd-core',
    minimum_version   => '5.8',
    purge             => true,
    purge_config      => true,
    recurse           => true,
    fqdnlookup        => false,
    service_enable    => $service_enable,
    service_ensure    => $service_ensure,
    collectd_hostname => $facts['networking']['fqdn'],
    typesdb           => [ '/usr/share/collectd/types.db', '/etc/collectd/types.db']
  }

  class { 'collectd::plugin::cpu': }
  class { 'collectd::plugin::df': fstypes => ['ext4'] }
  class { 'collectd::plugin::disk': }
  class { 'collectd::plugin::interface': }
  class { 'collectd::plugin::load': }
  class { 'collectd::plugin::memory': }
  class { 'collectd::plugin::processes': }
  class { 'collectd::plugin::vmem': }

  if $graphite_host {
    class { 'collectd::plugin::write_graphite':
      carbons => { $graphite_host => { 'graphitehost' => $graphite_host } }
    }
  }
}
