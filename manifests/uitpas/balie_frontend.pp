class profiles::uitpas::balie_frontend (
  Boolean $deployment = true
) inherits ::profiles {

  if $deployment {
    include profiles::uitpas::balie_frontend::deployment
  }

  # include ::profiles::uitpas::balie_frontend::monitoring
  # include ::profiles::uitpas::balie_frontend::metrics
  # include ::profiles::uitpas::balie_frontend::backup
  # include ::profiles::uitpas::balie_frontend::logging
}
