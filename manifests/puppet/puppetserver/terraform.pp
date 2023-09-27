class profiles::puppet::puppetserver::terraform (
  String  $bucket,
  Boolean $use_iam_role = true
) inherits ::profiles {

  $iam_role_mount_option = $use_iam_role ? {
    true  => 'iam_role=auto',
    false => undef
  }

  $mount_options = ['_netdev', 'nonempty', 'ro', 'nosuid', 'allow_other', 'multireq_max=5', 'uid=452', 'gid=452', $iam_role_mount_option]

  realize Group['puppet']
  realize User['puppet']

  include profiles::s3fs

  file { 'puppetserver-terraform-data':
    ensure  => 'directory',
    path    => '/etc/puppetlabs/code/data/terraform',
    owner   => 'puppet',
    group   => 'puppet',
    require => [Group['puppet'], User['puppet']]
  }

  mount { 'puppetserver-terraform-data':
    ensure   => 'mounted',
    device   => $bucket,
    name     => '/etc/puppetlabs/code/data/terraform',
    fstype   => 'fuse.s3fs',
    options  => join($mount_options.filter |$option| { $option }, ','),
    remounts => false,
    atboot   => true,
    require  => [File['puppetserver-terraform-data'], Class['profiles::s3fs']]
  }
}
