class profiles::google::gcsfuse (
  Optional[String] $credentials_source = undef
) inherits ::profiles {

  realize Apt::Source['publiq-tools']
  realize Package['gcsfuse']

  file { '/etc/gcsfuse':
    ensure => 'directory'
  }

  if $credentials_source {
    file { 'gcsfuse-credentials':
      ensure  => 'file',
      path    => '/etc/gcsfuse/credentials.json',
      source  => $credentials_source,
      require => File['/etc/gcsfuse']
    }
  }
}
