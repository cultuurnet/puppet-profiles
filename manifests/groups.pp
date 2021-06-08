class profiles::groups {

  @group { 'aptly':
    ensure => 'present',
    gid    => '450'
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
