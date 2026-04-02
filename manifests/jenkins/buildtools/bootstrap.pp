class profiles::jenkins::buildtools::bootstrap inherits ::profiles {

  # Only add packages here that are available in the official Ubuntu
  # repositories. All packages we build ourselves should go in the
  # jenkins::buildtools::extra profile (or another specific buildtools
  # profile).

  realize Package['git']
  realize Package['build-essential']
  realize Package['debhelper']
}
