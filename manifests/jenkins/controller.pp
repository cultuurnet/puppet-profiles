class profiles::jenkins::controller (
  Stdlib::Httpurl           $url,
  String                    $admin_password,
  String                    $version                      = 'latest',
  Boolean                   $lvm                          = false,
  Optional[String]          $volume_group                 = undef,
  Optional[String]          $volume_size                  = undef,
  Optional[String]          $certificate                  = undef,
  Optional[Stdlib::Httpurl] $docker_registry_url          = undef,
  Optional[String]          $docker_registry_credentialid = undef,
  Variant[Array,Hash]       $credentials                  = [],
  Variant[Array,Hash]       $global_libraries             = [],
  Variant[Array,Hash]       $pipelines                    = [],
  Variant[Array,Hash]       $users                        = []
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

  class { '::profiles::jenkins::controller::service': }

  class { '::profiles::jenkins::cli':
    version        => $version,
    controller_url => 'http://127.0.0.1:8080/'
  }

  class { '::profiles::jenkins::controller::configuration':
    url                          => $url,
    admin_password               => $admin_password,
    docker_registry_url          => $docker_registry_url,
    docker_registry_credentialid => $docker_registry_credentialid,
    credentials                  => $credentials,
    global_libraries             => $global_libraries,
    pipelines                    => $pipelines,
    users                        => $users,
    require                      => [ Class['profiles::jenkins::controller::service'], Class['profiles::jenkins::cli']]
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
