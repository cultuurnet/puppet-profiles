## This profile/module installs and configures aptly.
class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = '',
) {

  contain ::profiles

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    install_repo         => true,
    repo_location        => 'http://aptly.publiq.be',
    repo_keyserver       => 'hkps.pool.sks-keyservers.net',
    repo_key             => 'ED75B5A4483DA07C',
    api_port             => '8080',
    api_nolock           => true,
    enable_api           => true,

    #release  => $aptly::repo_release,
    #repos    => $aptly::repo_repos,

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
}
