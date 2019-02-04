class profiles::groups {

  @group { 'borgbackup':
    ensure => 'present',
    gid    => '1001'
  }
}
