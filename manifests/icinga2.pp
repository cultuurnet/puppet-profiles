class profiles::icinga2 (
  Variant[Stdlib::Ipv4, Array[Stdlib::Ipv4]] $nrpe_allowed_hosts = []
) inherits ::profiles {

  include ::profiles::firewall::rules

  class {'::icinga2::nrpe':
    nrpe_allowed_hosts => concat(['127.0.0.1', $facts['networking']['ip']], $nrpe_allowed_hosts)
  }

  realize Firewall['200 accept NRPE traffic']

  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_args => '-w $ARG1$ -c $ARG2$ -p $ARG3$',
    nrpe_plugin_name => 'check_disk'
  }

  icinga2::nrpe::command { 'check_diskstats':
    nrpe_plugin_args => '-w10% -c5% --all',
    nrpe_plugin_name => 'check_disk'
  }

  @@::icinga2::object::host { $facts['networking']['fqdn']:
    display_name     => $facts['networking']['fqdn'],
    ipv4_address     => $facts['networking']['ip'],
    target_dir       => '/etc/icinga2/objects/hosts',
    target_file_name => "${facts['networking']['fqdn']}.conf",
    vars             => {
      distro              => $facts['os']['name'],
      os                  => $facts['kernel'],
      virtual_machine     => $facts['is_virtual'],
      puppet_certname     => $facts['clientcert'],
      puppet_environment  => $environment
    }
  }

  realize Apt::Source['publiq-tools']

  package { 'icinga2-plugins-systemd-service':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }
}
