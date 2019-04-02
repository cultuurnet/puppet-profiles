class profiles::users {

  @user { 'ubuntu':
    ensure         => 'present',
    gid            => 'ubuntu',
    home           => '/home/ubuntu',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '1000'
  }

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
