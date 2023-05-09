class profiles::collectd (
  Optional[String] $graphite_host = undef
) inherits ::profiles {

  collectd::typesdb { '/etc/collectd/types.db':
    path   => '/etc/collectd/types.db'
  }

  class { '::collectd':
    manage_repo       => false,
    package_name      => 'collectd-core',
    purge             => true,
    purge_config      => true,
    recurse           => true,
    fqdnlookup        => false,
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

  if $graphite_host {
    class { 'collectd::plugin::write_graphite':
      carbons => { $graphite_host => { 'graphitehost' => $graphite_host } }
    }
  }
}
