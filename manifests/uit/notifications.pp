class profiles::uit::notifications (
  String  $database_password,
  Boolean $deployment        = true
)  inherits ::profiles {

  $database_name = 'uit_api'
  $database_user = 'uit_notifications'

  include ::profiles::nodejs

  realize Group['www-data']
  realize User['www-data']

  @@profiles::mysql::app_user { $database_user:
    database => $database_name,
    password => $database_password,
    remote   => true,
    tag      => $environment
  }

  if $deployment {
    include ::profiles::uit::notifications::deployment

    Group['www-data'] -> Class['profiles::uit::notifications::deployment']
    User['www-data'] -> Class['profiles::uit::notifications::deployment']
    Class['profiles::nodejs'] -> Class['profiles::uit::notifications::deployment']
  }

  # include ::profiles::uit::notifications::monitoring
  # include ::profiles::uit::notifications::metrics
  # include ::profiles::uit::notifications::backup
  # include ::profiles::uit::notifications::logging

}
