class profiles::deployment {

  contain ::profiles

  file { 'update_facts':
    ensure => 'file',
    group  => 'root',
    mode   => '0755',
    owner  => 'root',
    path   => '/usr/local/bin/update_facts',
    source => 'puppet:///modules/profiles/deployment/update_facts'
  }
}
