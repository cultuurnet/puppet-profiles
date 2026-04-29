define profiles::ssh::sshd_config (
  Enum['present', 'absent'] $ensure = 'present',
  Variant                   $value  = undef
) {

  case $ensure {
    'present': {
      if $value {
        $augeas_command = "set ${title} '${value}'"
      } else {
        fail("Value cannot be nil when ensure is 'present'")
      }
    }
    'absent': {
      $augeas_command = "rm ${title}"
    }
  }

  augeas { "Sshd_config ${title}":
    lens    => 'Sshd.lns',
    incl    => '/etc/ssh/sshd_config',
    context => '/files/etc/ssh/sshd_config',
    changes => $augeas_command
  }
}
