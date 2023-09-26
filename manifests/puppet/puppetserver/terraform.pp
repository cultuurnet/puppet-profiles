class profiles::puppet::puppetserver::terraform (
  String $bucketpath
) inherits ::profiles {

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
    device   => $bucketpath,
    name     => '/etc/puppetlabs/code/data/terraform',
    fstype   => 'fuse.s3fs',
    options  => '_netdev,nonempty,ro,nosuid,allow_other,multireq_max=5,uid=452,gid=452',
    remounts => false,
    atboot   => true,
    require  => [File['puppetserver-terraform-data'], Class['profiles::s3fs']]
  }
}
