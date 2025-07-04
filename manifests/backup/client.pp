class profiles::backup::client (
   Optional[String] $private_key    = lookup('data::backup::client::private_key', Optional[String], 'first', undef),
   Optional[String] $borg_server    = lookup('data::backup::server', Optional[String], 'first', undef),
   Hash   $configurations = {}
 ) inherits ::profiles {

  realize Apt::Source['publiq-tools']

  Sshkey <<| title == 'backup' |>>

  $borg_user      = 'borgbackup'
  $borg_datadir   = '/data/borgbackup'
  $borg_defaults  = {
    'type'           => 'borg',
    'borg_rsh'       => 'ssh -i /root/.ssh/backup_rsa',
    'job_verbosity'  => '1',
    'job_mailto'     => 'infra+cron@publiq.be',
    'options'        => {
      'compression'    => 'zlib,9',
      'keep_within'    => '24H',
      'keep_daily'     => '7',
      'keep_weekly'    => '5',
      'keep_monthly'   => '2',
      'checks'         => [
        'repository',
        'archives'
      ],
      'check_last'   => '1'
    }
  }

  if empty($configurations) {
    $borg_config = {}
  } else {
    # generates a hash containing each entry in profiles::backup::client::configurations
    # values in the $configurations variable are merged with the $borg_defaults
    #
    $borg_config = $configurations.reduce({}) |$key, $value| {
      $key + { $value[0] => $borg_defaults + $configurations[$value[0]] + {'repository' => "${borg_user}@${borg_server}:${borg_datadir}/${facts['clientcert']}-${value[0]}"} }
    }
  }

  class { 'borgbackup':
    configurations => $borg_config
  }

  file { '/root/.ssh':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700'
  }

  file { '/root/.ssh/backup_rsa':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => $private_key
  }

  Apt::Source['publiq-tools'] -> Class['borgbackup']
}
