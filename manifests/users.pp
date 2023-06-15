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

  @user { 'puppet':
    ensure         => 'present',
    gid            => 'puppet',
    home           => '/opt/puppetlabs/server/data/puppetserver',
    managehome     => false,
    purge_ssh_keys => true,
    shell          => '/usr/sbin/nologin',
    uid            => '452'
  }

  @user { 'postgres':
    ensure         => 'present',
    gid            => 'postgres',
    home           => '/var/lib/postgresql',
    managehome     => false,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '453'
  }

  @user { 'puppetdb':
    ensure         => 'present',
    gid            => 'puppetdb',
    home           => '/opt/puppetlabs/server/data/puppetdb',
    managehome     => false,
    purge_ssh_keys => true,
    shell          => '/usr/sbin/nologin',
    uid            => '454'
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

  @user { 'www-data':
    ensure         => 'present',
    gid            => 'www-data',
    home           => '/var/www',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/usr/sbin/nologin',
    uid            => '33'
  }

  @user { 'fuseki':
    ensure         => 'present',
    gid            => 'fuseki',
    home           => '/home/fuseki',
    managehome     => true,
    purge_ssh_keys => true,
    shell          => '/bin/bash',
    uid            => '1002'
  }
}
