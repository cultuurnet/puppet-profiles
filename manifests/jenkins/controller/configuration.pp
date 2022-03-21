class profiles::jenkins::controller::configuration(
  Stdlib::Httpurl            $url,
  String                     $admin_password,
  Variant[Hash, Array[Hash]] $credentials      = [],
  Variant[Hash, Array[Hash]] $global_libraries = [],
  Variant[Hash, Array[Hash]] $pipelines        = [],
  Variant[Hash, Array[Hash]] $users            = []
) inherits ::profiles {

  $plain_credentials       = [$credentials].flatten.filter |$credential| { $credential['type'] == 'string' or $credential['type'] == 'file' }
  $private_key_credentials = [$credentials].flatten.filter |$credential| { $credential['type'] == 'private_key' }
  $aws_credentials         = [$credentials].flatten.filter |$credential| { $credential['type'] == 'aws' }

  profiles::jenkins::plugin { 'swarm': }
  profiles::jenkins::plugin { 'mailer': }
  profiles::jenkins::plugin { 'copyartifact': }
  profiles::jenkins::plugin { 'ws-cleanup': }
  profiles::jenkins::plugin { 'slack': }
  profiles::jenkins::plugin { 'workflow-aggregator': }
  profiles::jenkins::plugin { 'pipeline-utility-steps': }
  profiles::jenkins::plugin { 'ssh-steps': }
  profiles::jenkins::plugin { 'blueocean': }

  profiles::jenkins::plugin { 'git':
    configuration => {
                       'user_name'  => 'publiq Jenkins',
                       'user_email' => 'jenkins@publiq.be'
                     },
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'configuration-as-code':
    configuration => {
                       'url'            => $url,
                       'admin_password' => $admin_password
                     },
    require       => Profiles::Jenkins::Plugin['mailer'],
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'plain-credentials':
    configuration => $plain_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'ssh-credentials':
    configuration => $private_key_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'aws-credentials':
    configuration => $aws_credentials,
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'workflow-cps-global-lib':
    configuration => [$global_libraries].flatten,
    require       => [ Profiles::Jenkins::Plugin['git'], Profiles::Jenkins::Plugin['ssh-credentials']],
    notify        => Class['profiles::jenkins::controller::configuration::reload']
  }

  profiles::jenkins::plugin { 'job-dsl':
    configuration => [$pipelines].flatten,
    require       => [ Profiles::Jenkins::Plugin['git'], Profiles::Jenkins::Plugin['ssh-credentials']],
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

  class { '::profiles::jenkins::controller::configuration::reload': }

  class { '::profiles::jenkins::cli::credentials':
    user     => 'admin',
    password => $admin_password,
    require  => Class['profiles::jenkins::controller::configuration::reload']
  }
}
