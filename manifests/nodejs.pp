class profiles::nodejs {

  contain ::profiles

  include ::profiles::repositories

  realize Apt::Source['nodejs_10.x']
  realize Profiles::Apt::Update['nodejs_10.x']

  contain ::nodejs

  Profiles::Apt::Update['nodejs_10.x'] -> Class['nodejs']
}
