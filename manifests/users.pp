class profiles::users inherits ::profiles {

  @user { 'aptly':
    ensure         => 'present',
    gid            => 'aptly',
    home           => '/home/aptly',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '450'
  }

  @user { 'jenkins':
    ensure         => 'present',
    gid            => 'jenkins',
    home           => '/var/lib/jenkins',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '451'
  }

  @user { 'ubuntu':
    ensure         => 'present',
    gid            => 'ubuntu',
    home           => '/home/ubuntu',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '1000'
  }

  @user { 'vagrant':
    ensure         => 'present',
    gid            => 'vagrant',
    home           => '/home/vagrant',
    managehome     => true,
    purge_ssh_keys => false,
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
