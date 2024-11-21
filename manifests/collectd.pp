class profiles::collectd (
  Boolean                                  $enable         = true,
  Optional[Variant[String, Array[String]]] $graphite_hosts = undef
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
    purge             => true,
    purge_config      => true,
    recurse           => true,
    fqdnlookup        => false,
    service_enable    => $service_enable,
    service_ensure    => $service_ensure,
    collectd_hostname => $facts['fqdn'],
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

  if $graphite_hosts {
    class { 'collectd::plugin::write_graphite':
      carbons => [$graphite_hosts].flatten.reduce({}) |Hash $all_carbons, String $graphite_host| { $all_carbons + { $graphite_host => { 'graphitehost' => $graphite_host } } }
    }
  }
}
