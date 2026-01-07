class profiles::docker (
  Boolean          $experimental   = false,
  Boolean          $schedule_prune = false,
  Boolean          $lvm            = false,
  Optional[String] $volume_group   = undef,
  Optional[String] $volume_size    = undef,
  Hash[String, Hash] $jenkins_agent_images = {}
) inherits ::profiles {

  $data_dir = '/var/lib/docker'

  realize Apt::Source['publiq-tools']
  realize Apt::Source['docker']

  if $lvm {
    unless ($volume_group and $volume_size) {
      fail("with LVM enabled, expects a value for both 'volume_group' and 'volume_size'")
    }

    profiles::lvm::mount { 'dockerdata':
      volume_group => $volume_group,
      size         => $volume_size,
      mountpoint   => '/data/docker',
      fs_type      => 'ext4',
      owner        => 'root',
      group        => 'root'
    }

    mount { $data_dir:
      ensure  => 'mounted',
      device  => '/data/docker',
      fstype  => 'none',
      options => 'rw,bind',
      require => [Profiles::Lvm::Mount['dockerdata'], File[$data_dir]],
      before  => Class['docker']
    }
  }

  package { 'docker-compose':
    ensure  => 'present',
    require => Apt::Source['publiq-tools']
  }

  if $experimental {
    realize Package['qemu-user-static']
  }

  file { $data_dir:
    ensure => 'directory',
    before => Class['docker']
  }

  class { '::docker':
    use_upstream_package_source => false,
    docker_users                => [],
    extra_parameters            => [ "--experimental=${experimental}"],
    require                     => Apt::Source['docker']
  }

  cron { 'docker system prune':
    ensure      => $schedule_prune ? {
                     true  => 'present',
                     false => 'absent'
                   },
    command     => '/usr/bin/docker system prune -f -a --volumes',
    environment => ['MAILTO=infra+cron@publiq.be'],
    hour        => '3',
    minute      => '30',
    weekday     => '0',
    require     => Class['docker']
  }

  # Pull Jenkins agent Docker images if configured
  if !empty($jenkins_agent_images) {
    $jenkins_agent_images.each |$image_name, $image_config| {
      $image_config['versions'].each |$version, $version_config| {
        $full_tag = "${image_name}:${version}"
        
        # Copy Dockerfile from module files
        $dockerfile_basename = basename($image_name)
        $dockerfile_path = "/opt/jenkins-docker/${dockerfile_basename}-${version}-Dockerfile"

        file { $dockerfile_path:
          ensure => 'file',
          source => $version_config['dockerfile_source'],
          owner  => 'root',
          group  => 'root',
          mode   => '0644',
        }
        
          # Pull Jenkins agent images
          $jenkins_agent_images.each |$image_name| {
            exec { "docker_pull_${image_name}":
              command => "docker pull ${image_name}",
              unless  => "docker image inspect ${image_name} > /dev/null 2>&1",
              require => Class['docker'],
            }
          }

        # Build the image
        # exec { "docker_build_${image_name}_${version}":
        #   command => sprintf(
        #     'docker build -t %s %s -f %s /opt/jenkins-docker',
        #     $full_tag,
        #     $version_config['build_args'].map |$k, $v| { "--build-arg ${k}=${v}" }.join(' '),
        #     $dockerfile_path
        #   ),
        #   unless  => "docker image inspect ${full_tag} > /dev/null 2>&1",
        #   require => [
        #     File[$dockerfile_path],
        #     Class['docker'],
        #   ],
        #   logoutput => 'on_failure',
        # }
      }
    }
  }
}
