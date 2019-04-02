class profiles::groups {

  @group { 'ubuntu':
    ensure => 'present',
    gid    => '1000'
  }

  @group { 'borgbackup':
    ensure => 'present',
    gid    => '1001'
  }
}
