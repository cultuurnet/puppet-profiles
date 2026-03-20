class profiles::uit::mail_subscriptions::logging (
  Boolean $deployment = true
) inherits ::profiles {

  if $deployment {
    profiles::rsyslog::tag_filter { 'uit-mail-subscriptions':
      syslogtag   => 'uit-mail-subscriptions',
      destination => '/var/log/uit-mail-subscriptions.log'
    }
  }
}
