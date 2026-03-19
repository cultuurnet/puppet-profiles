class profiles::uit::api::logging (
  Boolean $deployment = true
) inherits ::profiles {

  if $deployment {
    profiles::rsyslog::tag_filter { 'uit-api':
      syslogtag   => 'uit-api',
      destination => '/var/log/uit-api.log'
    }
  }
}
