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

  @group { 'puppet':
    ensure => 'present',
    gid    => '452'
  }

  @group { 'postgres':
    ensure => 'present',
    gid    => '453'
  }

  @group { 'puppetdb':
    ensure => 'present',
    gid    => '454'
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

  @group { 'www-data':
    ensure => 'present',
    gid    => '33'
  }

  @group { 'fuseki':
    ensure => 'present',
    gid    => '1002'
  }
}
