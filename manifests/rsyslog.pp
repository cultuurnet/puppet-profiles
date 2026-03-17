class profiles::rsyslog {

  include ::rsyslog

  class { 'rsyslog::config':
    modules       => {
                       'imuxsock' => {},
                       'imklog'   => { 'config' => { 'permitnonkernelfacility' => 'on' } },
                       'omusrmsg' => { 'type' => 'builtin' },
                       'omfile'   => {
                                       'type'   => 'builtin',
                                       'config' => {
                                                     'fileOwner'      => 'syslog',
                                                     'fileGroup'      => 'adm',
                                                     'dirGroup'       => 'adm',
                                                     'fileCreateMode' => '0640',
                                                     'dirCreateMode'  => '0755'
                                                   }
                                     }
                     },
    global_config => {
                       'Umask' => {
                         'value'    => '0022',
                         'type'     => 'legacy',
                         'priority' => 01
                       },
                       'RepeatedMsgReduction' => {
                         'value' => 'on',
                         'type'  => 'legacy'
                       },
                       'PrivDropToUser' => {
                         'value' => 'syslog',
                         'type'  => 'legacy'
                       },
                       'PrivDropToGroup' => {
                         'value' => 'syslog',
                         'type'  => 'legacy'
                       },
                       'FileOwner' => {
                         'value' => 'syslog',
                         'type'  => 'legacy'
                       },
                       'FileGroup' => {
                         'value' => 'adm',
                         'type'  => 'legacy'
                       },
                       'FileCreateMode' => {
                         'value' => '0640',
                         'type'  => 'legacy'
                       },
                       'DirCreateMode' => {
                         'value' => '0755',
                         'type'  => 'legacy'
                       },
                       'WorkDirectory' => {
                         'value' => '/var/spool/rsyslog',
                         'type'  => 'legacy'
                       }
                     },
    actions       => {
                       'auth'     => {
                                       'type'     => 'omfile',
                                       'facility' => 'auth,authpriv.*',
                                       'target'   => '99_default.conf',
                                       'priority' => 10,
                                       'config'   => {
                                                       'file' => '/var/log/auth.log'
                                                     }
                                     },
                       'all_logs' => {
                                       'type'     => 'omfile',
                                       'facility' => '*.*;auth,authpriv.none',
                                       'target'   => '99_default.conf',
                                       'priority' => 20,
                                       'config'   => {
                                                       'file' => '/var/log/syslog'
                                                     }
                                     },
                       'kernel'   => {
                                       'type'     => 'omfile',
                                       'facility' => 'kern.*',
                                       'target'   => '99_default.conf',
                                       'priority' => 30,
                                       'config'   => {
                                                       'file' => '/var/log/kern.log'
                                                     }
                                     },
                       'mail'     => {
                                       'type'     => 'omfile',
                                       'facility' => 'mail.*',
                                       'target'   => '99_default.conf',
                                       'priority' => 40,
                                       'config'   => {
                                                       'file' => '/var/log/mail.log'
                                                     }
                                     },
                       'emerg'    => {
                                       'type'     => 'omusrmsg',
                                       'facility' => 'emerg.*',
                                       'target'   => '99_default.conf',
                                       'priority' => 50,
                                       'config'   => {
                                                       'users' => '*'
                                                     }
                                     }
    }
  }
}
