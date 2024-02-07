class profiles::uit::mail_subscriptions (
  String  $database_password,
  Boolean $deployment        = true
)  inherits ::profiles {

  $database_name = 'uit_api'
  $database_user = 'uit_mail_subscriptions'

  include ::profiles::nodejs

  realize Group['www-data']
  realize User['www-data']

  @@profiles::mysql::app_user { $database_user:
    user     => $database_user,
    database => $database_name,
    password => $database_password,
    tag      => $environment
  }

  if $deployment {
    include ::profiles::uit::mail_subscriptions::deployment

    Group['www-data'] -> Class['profiles::uit::mail_subscriptions::deployment']
    User['www-data'] -> Class['profiles::uit::mail_subscriptions::deployment']
    Class['profiles::nodejs'] -> Class['profiles::uit::mail_subscriptions::deployment']
  }

  # include ::profiles::uit::mail_subscriptions::monitoring
  # include ::profiles::uit::mail_subscriptions::metrics
  # include ::profiles::uit::mail_subscriptions::backup
  # include ::profiles::uit::mail_subscriptions::logging

}
