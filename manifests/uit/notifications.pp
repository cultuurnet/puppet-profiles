class profiles::uit::notifications (
  Boolean $deployment = true
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::uit::notifications::deployment

    Class['profiles::nodejs'] -> Class['profiles::uit::notifications::deployment']
  }

  # include ::profiles::uit::notifications::monitoring
  # include ::profiles::uit::notifications::metrics
  # include ::profiles::uit::notifications::backup
  # include ::profiles::uit::notifications::logging

}
