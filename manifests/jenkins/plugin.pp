define profiles::jenkins::plugin (
  Enum['present', 'absent']     $ensure        = 'present',
  Boolean                       $restart       = false,
  Optional[Variant[Array,Hash]] $configuration = undef
) {

  include ::profiles
  include ::profiles::jenkins::cli

  $config_dir = '/var/lib/jenkins/casc_config'

  $default_exec_attributes = {
    path      => ['/usr/local/bin', '/usr/bin', '/bin'],
    logoutput => 'on_failure',
    tries     => 5,
    try_sleep => 10,
    require   => Class['profiles::jenkins::cli']
  }

  if $ensure == 'absent' {
    $post_action = '-restart'

    exec { "jenkins plugin ${title}":
      command => "jenkins-cli disable-plugin ${title} ${post_action}",
      onlyif  => "jenkins-cli list-plugins ${title}",
      *       => $default_exec_attributes
    }
  } else {
    $post_action = $restart ? {
      true  => '-restart',
      false => '-deploy'
    }

    exec { "jenkins plugin ${title}":
      command => "jenkins-cli install-plugin ${title} ${post_action}",
      unless  => "jenkins-cli list-plugins ${title}",
      *       => $default_exec_attributes
    }

    unless empty($configuration) {
      realize Group['jenkins']
      realize User['jenkins']

      file { "${title} configuration":
        ensure  => 'file',
        path    => "${config_dir}/${title}.yaml",
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template("profiles/jenkins/plugin/${title}.yaml.erb")
      }
    }
  }
}
