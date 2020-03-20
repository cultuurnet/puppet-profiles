## This profile/module installs and configures aptly.
class profiles::aptly {

  contain ::profiles

  #Gets the aptly install key unless it is already there.
  exec { 'Get Install Key':
    command   => 'sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED75B5A4483DA07C',
    unless    => '[[ $(apt-key list | grep -w 4096R/483DA07C) ]] && true',
    path      => [ '/usr/local/bin', '/usr/bin'],
    logoutput => 'true',
  }

  # we need to do an apt-get update now that we have the aptly key.
  realize Profiles::Apt::Update['aptly']

  #This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    s3_publish_endpoints =>
    {
      'apt.publiq.be' =>
      {
        'region' => 'eu-west-1',
        'bucket' => 'apt.publiq.be'
      }
    }
  }
}
