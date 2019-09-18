class profiles::elasticsearch {

  contain ::profiles

  include ::profiles::repositories

  realize Apt::Source['elasticsearch']
  realize Profiles::Apt::Update['elasticsearch']

}
