## This profile/module installs and configures aptly.
class profiles::aptly {

  include aptly

  contain ::profiles

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
