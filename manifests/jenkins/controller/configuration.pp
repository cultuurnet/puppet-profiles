class profiles::jenkins::controller::configuration(
  Stdlib::Httpurl                               $url,
  String                                        $admin_password,
  Boolean                                       $mfa                       = false,
  Boolean                                       $role_based_authorization  = false,
  Boolean                                       $timestamps                = false,
  Enum['xterm', 'vga', 'css', 'gnome-terminal'] $output_colormap           = 'xterm',
  Integer[1]                                    $max_concurrent_builds     = 1,
  Optional[Stdlib::Httpurl]                     $docker_registry_url       = undef,
  Optional[String]                              $kubernetes_jnlp_image     = undef,
  Optional[String]                              $kubernetes_credentials_id = undef,
  Optional[Boolean]                             $kubernetes_use_file_kubeconfig = undef,
  Optional[String]                              $private_key               = undef,
  Variant[Hash, Array[Hash]]                    $credentials               = [],
  String                                        $github_hook_url           = '',
  Variant[Hash, Array[Hash]]                    $github_servers            = [],
  Variant[Hash, Array[Hash]]                    $global_libraries          = [],
  Variant[Hash, Array[Hash]]                    $pipelines                 = [],
  Variant[Hash, Array[Hash]]                    $views                     = [],
  Variant[Hash, Array[Hash]]                    $users                     = [],
  Optional[String]                              $puppetdb_url              = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $plain_credentials       = [$credentials].flatten.filter |$credential| { $credential['type'] == 'string' or $credential['type'] == 'file' or $credential['type'] == 'username_password' }
  $aws_credentials         = [$credentials].flatten.filter |$credential| { $credential['type'] == 'aws' }
  $github_app_credentials  = [$credentials].flatten.filter |$credential| { $credential['type'] == 'github_app' }
  $private_key_credentials = if $private_key {
                               [$credentials].flatten.filter |$credential| { $credential['type'] == 'private_key' } + [{ id => 'jenkins@jenkins.publiq.be', type => 'private_key', key => $private_key }]
                             } else {
                               [$credentials].flatten.filter |$credential| { $credential['type'] == 'private_key' }
                             }
  $github_configuration    = (!empty($github_hook_url) or !empty($github_servers)) ? {
    true    => {
                 'hook_url' => $github_hook_url,
                 'servers'  => [$github_servers].flatten
               },
    default => []
  }
  $configuration_as_code_configuration = $role_based_authorization ? {
    true    => {
                 'url'                      => $url,
                 'admin_password'           => $admin_password,
                 'views'                    => $views,
                 'pipelines'                => $pipelines,
                 'users'                    => $users,
                 'role_based_authorization' => true
               },
    default => {
                 'url'            => $url,
                 'admin_password' => $admin_password,
                 'views'          => $views
               }
  }

  profiles::jenkins::plugin { 'swarm': }
  profiles::jenkins::plugin { 'mailer': }
  profiles::jenkins::plugin { 'email-ext': }
  profiles::jenkins::plugin { 'copyartifact': }
  profiles::jenkins::plugin { 'ws-cleanup': }
  profiles::jenkins::plugin { 'junit-attachments': }
  profiles::jenkins::plugin { 'slack': }
  profiles::jenkins::plugin { 'workflow-aggregator': }
  profiles::jenkins::plugin { 'pipeline-utility-steps': }
  profiles::jenkins::plugin { 'ssh-steps': }
  profiles::jenkins::plugin { 'blueocean': }
  profiles::jenkins::plugin { 'uno-choice': }
  profiles::jenkins::plugin { 'parameterized-scheduler': }
  profiles::jenkins::plugin { 'pipeline-stage-view': }
  profiles::jenkins::plugin { 'build-token-root': }

  profiles::jenkins::plugin { 'role-strategy':
    before => Profiles::Jenkins::Plugin['configuration-as-code'],
    notify => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'git':
    configuration => {
                       'user_name'  => 'publiq Jenkins',
                       'user_email' => 'jenkins@publiq.be'
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'git-client':
    configuration => { 'hostkey_verification_strategy' => 'noHostKeyVerificationStrategy' },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'github':
    configuration => $github_configuration,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'configuration-as-code':
    configuration => $configuration_as_code_configuration,
    require       => Profiles::Jenkins::Plugin['mailer'],
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'plain-credentials':
    configuration => $plain_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'ssh-credentials':
    configuration => [$private_key_credentials].flatten,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'aws-credentials':
    configuration => $aws_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'github-branch-source':
    configuration => $github_app_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'pipeline-groovy-lib':
    configuration => [$global_libraries].flatten,
    require       => [ Profiles::Jenkins::Plugin['git'], Profiles::Jenkins::Plugin['ssh-credentials']],
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'throttle-concurrents':
    configuration => { 'max_concurrent_builds' => $max_concurrent_builds },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'job-dsl':
    configuration => {
                       'admin_password'    => $admin_password,
                       'concurrent_builds' => $max_concurrent_builds ? {
                                                1       => false,
                                                default => true
                                              },
                       'pipelines'         => $pipelines
                     },
    require       => [ Profiles::Jenkins::Plugin['git'], Profiles::Jenkins::Plugin['ssh-credentials']],
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'docker-workflow':
    configuration => {
                       'docker_label'        => 'docker',
                       'docker_registry_url' => $docker_registry_url
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  $kubeconfig_credentials = $plain_credentials.filter |$credential| {
    $credential['type'] == 'file' and $credential['id'] == $kubernetes_credentials_id
  }
  $use_file_kubeconfig = $kubernetes_use_file_kubeconfig ? {
    undef   => !$kubeconfig_credentials.empty,
    default => $kubernetes_use_file_kubeconfig,
  }

  if $use_file_kubeconfig {
    if $kubeconfig_credentials.length != 1 or $kubeconfig_credentials[0]['content'] !~ String[1] {
      fail('File-backed Kubernetes authentication requires one matching file credential with kubeconfig content')
    }

    # Fabric8 can rerun the kubeconfig exec command on watch reconnect when it can reread the file.
    $kubeconfig_dir = '/var/lib/jenkins/.kube'
    file { $kubeconfig_dir:
      ensure => directory,
      owner  => 'jenkins',
      group  => 'jenkins',
      mode   => '0700',
    }
    file { "${kubeconfig_dir}/config":
      ensure    => file,
      owner     => 'jenkins',
      group     => 'jenkins',
      mode      => '0600',
      content   => Sensitive($kubeconfig_credentials[0]['content']),
      show_diff => false,
      require   => File[$kubeconfig_dir],
      before    => Profiles::Jenkins::Plugin['kubernetes'],
    }
  }

  $cloud_credentials_id = $use_file_kubeconfig ? {
    true    => undef,
    default => $kubernetes_credentials_id,
  }
  profiles::jenkins::plugin { 'kubernetes':
    configuration => {
      'jnlp_image'       => $kubernetes_jnlp_image,
      'credentials_id'   => $cloud_credentials_id
    },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'openmfa':
    ensure        => $mfa ? {
                       true  => 'present',
                       false => 'absent'
                     },
    configuration => {
                       'issuer' => "Jenkins publiq (${environment})"
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'timestamper':
    ensure        => $timestamps ? {
                       true  => 'present',
                       false => 'absent'
                     },
    configuration => {
                       'elapsed_time_format' => "'<b>'HH:mm:ss.SSS'</b> '",
                       'system_time_format'  => "'<b>'yyyy-MM-dd'T'HH:mm:ss.SSSZ'</b> '"
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'ansicolor':
    configuration => {
                       'colormap_name' => $output_colormap
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  unless empty($users) {
    file { 'jenkins users':
      ensure  => 'file',
      path    => '/var/lib/jenkins/casc_config/users.yaml',
      content => template('profiles/jenkins/users.yaml.erb'),
      require => Profiles::Jenkins::Plugin['mailer'],
      notify  => Class['profiles::jenkins::controller::configuration::reload']
    }
  }

  if $puppetdb_url {
    profiles::puppet::puppetdb::cli { 'jenkins':
      certificate_name => "jenkins-controller-${environment}",
      server_urls      => $puppetdb_url
    }
  }

  class { '::profiles::jenkins::controller::configuration::private_key':
    key => $private_key
  }

  class { '::profiles::jenkins::controller::configuration::reload': }

  class { '::profiles::jenkins::cli::credentials':
    user     => 'admin',
    password => $admin_password,
    require  => Class['profiles::jenkins::controller::configuration::reload']
  }
}
