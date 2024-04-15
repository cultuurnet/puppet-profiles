class profiles::uitid::frontend_auth0 (
  Boolean $deployment = true
) inherits ::profiles {

  if $deployment {
    include profiles::uitid::frontend_auth0::deployment
  }

  # include ::profiles::uitid::frontend_auth0::logging
  # include ::profiles::uitid::frontend_auth0::monitoring
  # include ::profiles::uitid::frontend_auth0::metrics
  # include ::profiles::uitid::frontend_auth0::backup
}
