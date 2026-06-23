class profiles::jenkins::controller (
  Stdlib::Httpurl            $url,
  String                     $admin_password,
  String                     $version                  = 'latest',
  Boolean                    $mfa                      = false,
  Boolean                    $role_based_authorization = false,
  Integer[1]                 $max_concurrent_builds    = 1,
  Boolean                    $lvm                      = false,
  Optional[String]           $volume_group             = undef,
  Optional[String]           $volume_size              = undef,
  Optional[String]           $certificate              = undef,
  Optional[Stdlib::Httpurl]  $docker_registry_url      = undef,
  Optional[String]           $private_key              = undef,
  Variant[Hash, Array[Hash]] $credentials              = [],
  String                     $github_hook_url          = '',
  Variant[Hash, Array[Hash]] $github_servers           = [],
  Variant[Hash, Array[Hash]] $global_libraries         = [],
  Variant[Hash, Array[Hash]] $pipelines                = [],
  Variant[Hash, Array[Hash]] $views                    = [],
  Variant[Hash, Array[Hash]] $users                    = [],
  Optional[String]           $puppetdb_url             = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  include ::profiles::java

  $hostname   = split($url, '/')[2]

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'jenkins':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/jenkins/jobs',
      fs_type      => 'ext4',
      owner        => 'jenkins',
      group        => 'jenkins',
      require      => [Group['jenkins'], User['jenkins']]
    }

    file { '/var/lib/jenkins/jobs':
      ensure  => 'link',
      target  => '/data/jenkins/jobs',
      force   => true,
      owner   => 'jenkins',
      group   => 'jenkins',
      require => Profiles::Lvm::Mount['jenkins'],
      before  => Class['profiles::jenkins::controller::install']
    }
  }

  class { '::profiles::jenkins::controller::install':
    version => $version,
    require => Class['profiles::java'],
    notify  => Class['profiles::jenkins::controller::service']
  }

  class { '::profiles::jenkins::controller::service':
    subscribe => Class['profiles::java']
  }

  class { '::profiles::jenkins::cli':
    version        => $version,
    controller_url => 'http://127.0.0.1:8080/'
  }

  class { '::profiles::jenkins::controller::configuration':
    url                      => $url,
    admin_password           => $admin_password,
    mfa                      => $mfa,
    role_based_authorization => $role_based_authorization,
    max_concurrent_builds    => $max_concurrent_builds,
    docker_registry_url      => $docker_registry_url,
    private_key              => $private_key,
    credentials              => $credentials,
    github_hook_url          => $github_hook_url,
    github_servers           => $github_servers,
    global_libraries         => $global_libraries,
    pipelines                => $pipelines,
    views                    => $views,
    users                    => $users,
    puppetdb_url             => $puppetdb_url,
    require                  => [ Class['profiles::jenkins::controller::service'], Class['profiles::jenkins::cli']]
  }

  if $certificate {
    profiles::apache::vhost::redirect { "http://${hostname}":
      destination => "https://${hostname}"
    }

    profiles::apache::vhost::reverse_proxy { "https://${hostname}":
      destination           => 'http://127.0.0.1:8080/',
      certificate           => $certificate,
      preserve_host         => true,
      allow_encoded_slashes => 'nodecode',
      proxy_keywords        => 'nocanon',
      support_websockets    => true
    }

    Profiles::Apache::Vhost::Reverse_proxy["https://${hostname}"] -> Class['profiles::jenkins::cli']
  } else {
    profiles::apache::vhost::reverse_proxy { "http://${hostname}":
      destination           => 'http://127.0.0.1:8080/',
      preserve_host         => true,
      allow_encoded_slashes => 'nodecode',
      proxy_keywords        => 'nocanon',
      support_websockets    => true
    }

    Profiles::Apache::Vhost::Reverse_proxy["http://${hostname}"] -> Class['profiles::jenkins::cli']
  }
}
