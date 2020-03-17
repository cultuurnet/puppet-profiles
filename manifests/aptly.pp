## This profile/module installs, configures, and maintains aptly.
class profiles::aptly {

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
