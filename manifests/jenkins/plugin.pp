define profiles::jenkins::plugin (
  Enum['present', 'absent'] $ensure  = 'present',
  Boolean                   $restart = false
) {

  include ::profiles
  include ::profiles::jenkins::cli

  $default_exec_attributes = {
    path      => ['/usr/local/bin', '/usr/bin'],
    logoutput => 'on_failure',
    tries     => 12,
    try_sleep => 30,
    require   => Class['profiles::jenkins::cli']
  }

  if $ensure == 'absent' {
    $post_action = $restart ? {
      true  => '-restart',
      false => ''
    }

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
  }
}
