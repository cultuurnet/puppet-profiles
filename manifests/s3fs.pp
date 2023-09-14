class profiles::s3fs (
  String           $version               = 'installed',
  Optional[String] $aws_access_key_id     = undef,
  Optional[String] $aws_secret_access_key = undef
) inherits ::profiles {

  package { 's3fs':
    ensure  => $version,
  }

  if ($aws_access_key_id and $aws_secret_access_key) {
    $ensure  = 'file'
    $content = "${aws_access_key_id}:${aws_secret_access_key}"
  } else {
    $ensure  = 'absent'
    $content = undef
  }

  file { 's3fs-passwordfile':
    ensure  => $ensure,
    path    => '/etc/passwd-s3fs',
    content => $content
  }
}
