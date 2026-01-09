class profiles::collectd (
  Boolean                        $enable         = true,
  Variant[String, Array[String]] $graphite_hosts = []
) inherits ::profiles {

  collectd::typesdb { '/etc/collectd/types.db':
    path => '/etc/collectd/types.db'
  }

  class { '::collectd':
    manage_repo       => false,
    package_name      => 'collectd-core',
    minimum_version   => '5.8',
    purge             => true,
    purge_config      => true,
    recurse           => true,
    fqdnlookup        => false,
    service_enable    => $enable,
    service_ensure    => $enable ? {
                           true  => 'running',
                           false => 'stopped'
                         },
    collectd_hostname => $facts['networking']['fqdn'],
    typesdb           => [
                           '/usr/share/collectd/types.db',
                           '/etc/collectd/types.db'
                         ]
  }

  class { 'collectd::plugin::cpu': }
  class { 'collectd::plugin::df': fstypes => ['ext4'] }
  class { 'collectd::plugin::disk': }
  class { 'collectd::plugin::interface': interfaces => ['eth0', 'lo'] }
  class { 'collectd::plugin::load': }
  class { 'collectd::plugin::memory': }
  class { 'collectd::plugin::processes': }
  class { 'collectd::plugin::vmem': }

  unless empty($graphite_hosts) {
    class { 'collectd::plugin::write_graphite':
      carbons => [$graphite_hosts].flatten.reduce({}) |Hash $all, String $host| {
                   $all + { $host => { 'graphitehost' => $host } } }
    }
  }
}
