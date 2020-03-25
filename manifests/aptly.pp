## This profile/module installs and configures aptly.
class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = '',
) {

  contain ::profiles

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    install_repo         => true, # Tell aptly to install the 
    repo_location        => 'http://repo.aptly.info/', # Where to get the deb file
    repo_keyserver       => 'hkps.pool.sks-keyservers.net', # Where to get the install key
    repo_key             => 'ED75B5A4483DA07C',
    api_port             => '8080',
    api_nolock           => true,
    enable_api           => true,
    uid                  => '0',

    s3_publish_endpoints =>
    {
      'apt.publiq.be' =>
      {
        'region'             => 'eu-west-1',
        'bucket'             => 'apt.publiq.be',
        'awsAccessKeyID'     => $awsaccesskeyid,
        'awsSecretAccessKey' => $awssecretaccesskey
      }
    }
  }

  # According to the aptly module documenttion, aptly API service can not start without at least one repo. 
  aptly::repo {'initial_repo':
    ensure => present,
    uid    => '0',
  }
}
