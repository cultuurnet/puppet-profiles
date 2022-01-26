class profiles::apt inherits ::profiles {

  class { '::apt':
    update => { 'frequency' => 'always' },
    stage  => 'pre'
  }

  cron { 'apt clean daily':
    command     => '/usr/bin/apt-get clean',
    environment => [ 'MAILTO=infra@publiq.be'],
    hour        => '3',
    minute      => '0',
    require     => Class['apt']
  }
}
