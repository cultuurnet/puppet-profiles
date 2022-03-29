class profiles::groups inherits ::profiles {

  @group { 'docker':
    ensure => 'present',
    gid    => '300'
  }

  @group { 'aptly':
    ensure => 'present',
    gid    => '450'
  }

  @group { 'jenkins':
    ensure => 'present',
    gid    => '451'
  }

  @group { 'ubuntu':
    ensure => 'present',
    gid    => '1000'
  }

  @group { 'vagrant':
    ensure => 'present',
    gid    => '1000'
  }

  @group { 'borgbackup':
    ensure => 'present',
    gid    => '1001'
  }
}
