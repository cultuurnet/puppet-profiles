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
    command     => 'udevadm trigger /dev/nvme* && sleep 5',
    path        => ['/usr/sbin', '/usr/bin'],
    refreshonly => true,
    logoutput   => 'on_failure',
    onlyif      => 'ebsnvme-id /dev/nvme0',
    before      => Class['lvm'],
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

      $terraform_size_gb = lookup("terraform::volumes::ebs::${pv[5,-1]}::size", Optional[Integer], 'first', undef)

      if $terraform_size_gb and $facts['physical_volumes'][$pv] {
        $terraform_reported_volume_size_mb = ($terraform_size_gb * 1024)

        # The volume size derived from LVM is calculated as follows: each physical volume extent is 4MB, and the LVM
        # metadata uses 1MB at the start of the volume. So the actual layout for a volume that is turned into a PV
        # is the following:
        # *---------------------------------------------------------------------------------------------------*
        # | 1MB LVM metadata | Physical volume with size (extents * 4MB) | Remainder of volume, less than 4MB |
        # *---------------------------------------------------------------------------------------------------*
        # So, adding 1 extra extent is needed for a correct volume size on EBS volumes.
        $calculated_volume_size_from_pv_mb = ((Integer($facts['physical_volumes'][$pv]['pe_count']) + 1) * 4)

        if ($terraform_reported_volume_size_mb > $calculated_volume_size_from_pv_mb) {
          exec { "resize_pv_${pv}":
            command => "pvresize ${pv}",
            path    => ['/usr/sbin', '/usr/bin'],
            require => Physical_volume[$pv]
          }
        }
      }
    }

    volume_group { $vg_name:
      ensure           => 'present',
      physical_volumes => $vg_properties['physical_volumes']
    }
  }
}
