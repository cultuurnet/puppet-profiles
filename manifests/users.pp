class profiles::users {

  @user { 'borgbackup':
    ensure         => 'present',
    gid            => 'borgbackup',
    home           => '/home/borgbackup',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '1001'
  }
}
