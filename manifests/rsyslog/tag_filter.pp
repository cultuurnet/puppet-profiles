define profiles::rsyslog::tag_filter (
  String  $syslogtag,
  String  $destination,
  Integer $priority       = 50,
  Integer $retention_days = 7
) {

  include profiles::rsyslog
  include profiles::logrotate

  rsyslog::component::expression_filter { $title:
    priority     => 0,
    confdir      => '/etc/rsyslog.d',
    target       => "${priority}_${title}.conf",
    conditionals => {
                      'main' => {
                        'expression' => "\$syslogtag contains \"${syslogtag}\"",
                        'tasks'      => [
                                          {
                                            'action' => {
                                              'type'   => 'omfile',
                                              'config' => { 'file' => $destination }
                                            }
                                          },
                                          { 'stop' => true }
                                        ]
                      }
                    }
  }

  logrotate::rule { $title:
      path         => $destination,
      rotate       => $retention_days - 1,
      create_owner => 'root',
      create_group => 'adm',
      postrotate   => '/usr/lib/rsyslog/rsyslog-rotate',
      *            => $profiles::logrotate::default_rule_attributes
    }
}
