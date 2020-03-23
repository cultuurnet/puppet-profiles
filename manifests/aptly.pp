## This profile/module installs and configures aptly.
class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = ''
) {

  contain ::profiles

  # Gets the aptly install key unless it is already there.
  exec { 'Get Install Key':
    command   => 'sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-keys ED75B5A4483DA07C',
    unless    => 'apt-key list | /bin/grep -w Andrey',
    path      => [ '/usr/local/bin', '/usr/bin'],
    logoutput => 'true',
  }

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    s3_publish_endpoints =>
    {
      'apt.publiq.be' =>
      {
        'region'             => 'eu-west-1',
        'bucket'             => 'apt.publiq.be',
        'awsAccessKeyID'     => lookup('profiles::aptly::awsaccesskeyid'),
        'awsSecretAccessKey' => lookup('profiles::aptly::awssecretaccesskey')
      }
    }
  }

  # Start the apply service.
  # Quote from 
  exec { 'Start Aptly':
    command   => 'aptly api serve',
    unless    => 'sudo service aptly started',
    path      => [ '/usr/local/bin', '/usr/bin'],
    logoutput => 'true',
  }

  Exec['Get Install Key'] -> Exec['apt_update']
}
