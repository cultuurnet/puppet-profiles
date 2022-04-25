class profiles::uit::mail_subscriptions inherits ::profiles {

  include ::profiles::nodejs
  include ::profiles::uit::mail_subscriptions::deployment
  # include ::profiles::uit::mail_subscriptions::monitoring
  # include ::profiles::uit::mail_subscriptions::metrics
  # include ::profiles::uit::mail_subscriptions::backup
  # include ::profiles::uit::mail_subscriptions::logging

  Class['profiles::nodejs'] -> Class['profiles::uit::mail_subscriptions::deployment']
}
