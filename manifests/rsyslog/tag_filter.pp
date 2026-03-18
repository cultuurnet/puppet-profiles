define profiles::rsyslog::tag_filter (
  String  $syslogtag,
  String  $destination,
  Integer $priority    = 50
) {

  include profiles::rsyslog

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
}
