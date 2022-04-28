class profiles::uit::mail_subscriptions (
  Boolean $deployment = true
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::uit::mail_subscriptions::deployment

    Class['profiles::nodejs'] -> Class['profiles::uit::mail_subscriptions::deployment']
  }

  # include ::profiles::uit::mail_subscriptions::monitoring
  # include ::profiles::uit::mail_subscriptions::metrics
  # include ::profiles::uit::mail_subscriptions::backup
  # include ::profiles::uit::mail_subscriptions::logging

}
