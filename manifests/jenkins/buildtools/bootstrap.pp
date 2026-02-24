class profiles::jenkins::buildtools::bootstrap inherits ::profiles {

  # Only add packages here that are available in the official Ubuntu
  # repositories. All packages we build ourselves should go in the
  # jenkins::buildtools::homebuilt profile (or another specific buildtools
  # profile).

  realize Package['git']
  realize Package['jq']
  realize Package['build-essential']
  realize Package['debhelper']
  realize Package['mysql-client']
  realize Package['phantomjs']

  include profiles::ruby
}
