define profiles::jenkins::plugin (
  String                    $admin_user,
  String                    $admin_password,
  Enum['present', 'absent'] $ensure         = 'present'
) {

  include ::profiles

  $default_exec_attributes = {
    path      => ['/usr/local/bin', '/usr/bin'],
    logoutput => 'on_failure',
    require   => Package['jenkins-cli']
  }

  if $ensure == 'absent' {
    exec { "jenkins plugin ${title}":
      command => "jenkins-cli -auth ${admin_user}:${admin_password} -webSocket disable-plugin ${title}",
      onlyif  => "jenkins-cli -auth ${admin_user}:${admin_password} list-plugins ${title}",
      *       => $default_exec_attributes
    }
  } else {
    exec { "jenkins plugin ${title}":
      command   => "jenkins-cli -auth ${admin_user}:${admin_password} -webSocket install-plugin ${title} -deploy",
      unless    => "jenkins-cli -auth ${admin_user}:${admin_password} list-plugins ${title}",
      *         => $default_exec_attributes
    }
  }
}
