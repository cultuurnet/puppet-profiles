class profiles::nodejs (
  Integer $major_version = 10
) {

  contain ::profiles

  include ::profiles::apt::repositories

  realize Apt::Source["nodejs_${major_version}.x"]
  realize Profiles::Apt::Update["nodejs_${major_version}.x"]

  contain ::nodejs

  Profiles::Apt::Update["nodejs_${major_version}.x"] -> Class['nodejs']
}
