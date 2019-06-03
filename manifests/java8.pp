class profiles::java8 {

  contain ::profiles

  realize Apt::Source['cultuurnet-tools']

  file { '/var/cache':
    ensure => 'directory'
  }

  file { '/var/cache/oracle-jdk8-installer':
    ensure => 'directory'
  }

  wget::fetch { 'jdk-8u151-linux-x64.tar.gz':
    destination => '/var/cache/oracle-jdk8-installer/jdk-8u151-linux-x64.tar.gz',
    source      => 'https://s3-eu-west-1.amazonaws.com/udb3-vagrant/jdk-8u151-linux-x64.tar.gz',
    require     => File['/var/cache/oracle-jdk8-installer'],
    before      => Class['::java8']
  }

  class { '::java8':
    installer_version => '8u151-1~webupd8~0',
    manage_repos      => false,
    require           => Apt::Source['cultuurnet-tools']
  }
}
