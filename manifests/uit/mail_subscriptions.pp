class profiles::uit::mail_subscriptions (
  String  $database_password,
  Boolean $deployment        = true
)  inherits ::profiles {

  $database_name = 'uit_api'
  $database_user = 'uit_mail_subscriptions'

  include ::profiles::nodejs

  realize Group['www-data']
  realize User['www-data']

  # Disabled while two uit::api nodes coexist per environment (*02 -> *03 migration):
  # both would export this same resource and collecting it fails with a duplicate
  # resource error. The database user already exists on the current node.
  # @@profiles::mysql::app_user { "${database_user}@${database_name}":
  #   password => $database_password,
  #   tag      => $environment
  # }

  if $deployment {
    include ::profiles::uit::mail_subscriptions::deployment

    Group['www-data'] -> Class['profiles::uit::mail_subscriptions::deployment']
    User['www-data'] -> Class['profiles::uit::mail_subscriptions::deployment']
    Class['profiles::nodejs'] -> Class['profiles::uit::mail_subscriptions::deployment']
  }

  class { 'profiles::uit::mail_subscriptions::logging':
    deployment => $deployment
  }

  # include ::profiles::uit::mail_subscriptions::monitoring
  # include ::profiles::uit::mail_subscriptions::metrics
  # include ::profiles::uit::mail_subscriptions::backup
}
