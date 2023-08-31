class profiles::lvm (
  Hash $volume_groups = {}
) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  package { 'amazon-ec2-utils':
    ensure  => 'latest',
    require => Apt::Source['publiq-tools'],
    notify  => Exec['amazon-ec2-utils-udevadm-trigger']
  }

  exec { 'amazon-ec2-utils-udevadm-trigger':
    command     => 'udevadm trigger /dev/nvme*',
    path        => ['/usr/bin'],
    refreshonly => true,
    before      => Class['lvm']
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

  $volume_groups.each |String $vg_name, Hash $vg_properties| {
    [$vg_properties['physical_volumes']].flatten.each |String $pv| {
      physical_volume { $pv:
        ensure  => 'present',
        require => Class['lvm'],
        before  => Volume_group[$vg_name]
      }
    }

    volume_group { $vg_name:
      ensure           => 'present',
      physical_volumes => $vg_properties['physical_volumes']
    }
  }
}
