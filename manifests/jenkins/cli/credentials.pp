class profiles::jenkins::cli::credentials (
  String  $user,
  String  $password
) inherits ::profiles {

  $config_path                 = '/etc/jenkins-cli/cli.conf'
  $default_shellvar_attributes = {
                                   ensure   => 'present',
                                   target   => $config_path
                                 }

  shellvar { 'JENKINS_USER':
    variable => 'JENKINS_USER',
    value    => $user,
    *        => $default_shellvar_attributes
  }

  shellvar { 'JENKINS_PASSWORD':
    variable => 'JENKINS_PASSWORD',
    value    => $password,
    *        => $default_shellvar_attributes
  }
}
