class profiles::uit::frontend (
  Boolean $deployment = true
)  inherits ::profiles {

  include ::profiles::nodejs

  if $deployment {
    include ::profiles::uit::frontend::deployment

    Class['profiles::nodejs'] -> Class['profiles::uit::frontend::deployment']
  }

  # include ::profiles::uit::frontend::monitoring
  # include ::profiles::uit::frontend::metrics
  # include ::profiles::uit::frontend::backup
  # include ::profiles::uit::frontend::logging
}
