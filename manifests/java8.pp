class profiles::java8 {

  contain ::profiles

  realize Apt::Source['cultuurnet-tools']

  package { 'oracle-jdk8-archive':
    ensure  => '8u151',
    require => Apt::Source['cultuurnet-tools']
  }

  class { '::java8':
    installer_version => '8u151-1~webupd8~0',
    manage_repos      => false,
    require           => Package['oracle-jdk8-archive']
  }
}
