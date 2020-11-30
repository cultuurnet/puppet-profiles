define profiles::jenkins::plugin (
  String                    $admin_user,
  String                    $admin_password,
  Enum['present', 'absent'] $ensure         = 'present',
  Boolean                   $restart        = false
) {

  include ::profiles

  $default_exec_attributes = {
    path      => ['/usr/local/bin', '/usr/bin'],
    logoutput => 'on_failure',
    require   => Package['jenkins-cli']
  }

  if $ensure == 'absent' {
    $post_action = $restart ? {
      true  => '-restart',
      false => ''
    }

    exec { "jenkins plugin ${title}":
      command   => "jenkins-cli -auth ${admin_user}:${admin_password} disable-plugin ${title} ${post_action}",
      onlyif    => "jenkins-cli -auth ${admin_user}:${admin_password} list-plugins ${title}",
      *         => $default_exec_attributes,
      tries     => 12,
      try_sleep => 30,
    }
  } else {
    $post_action = $restart ? {
      true  => '-restart',
      false => '-deploy'
    }

    exec { "jenkins plugin ${title}":
      command   => "jenkins-cli -auth ${admin_user}:${admin_password} install-plugin ${title} ${post_action}",
      unless    => "jenkins-cli -auth ${admin_user}:${admin_password} list-plugins ${title}",
      *         => $default_exec_attributes,
      tries     => 12,
      try_sleep => 30,
    }
  }
}
