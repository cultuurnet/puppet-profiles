class profiles::apt inherits ::profiles {

  class { '::apt':
    update => { 'frequency' => 'always' },
    stage  => 'pre'
  }

  exec { 'disable apt news':
    command   => 'pro config set apt_news=false',
    path      => ['/usr/bin'],
    onlyif    => 'test True = $(pro config show apt_news | cut -d " " -f 2)',
    logoutput => 'on_failure',
    require   => Class['apt']
  }

  cron { 'apt clean daily':
    command     => '/usr/bin/apt-get clean',
    environment => [ 'MAILTO=infra+cron@publiq.be'],
    hour        => '3',
    minute      => '0',
    require     => Class['apt']
  }
}
