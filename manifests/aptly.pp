## This profile/module installs and configures aptly.
class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = '',
) {

  contain ::profiles

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    install_repo         => true, # Tell aptly to install from a repo
    repo_location        => 'http://repo.aptly.info/', # Where to get the deb file
    repo_keyserver       => 'hkps.pool.sks-keyservers.net', # Where to get the install key
    repo_key             => 'ED75B5A4483DA07C',
    port                 => '80',
    api_nolock           => true,
    enable_api           => true,

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

  class{ 'apache':
    default_vhost => false,
  }

  apache::vhost { 'apt-private_80':
    docroot         => '/var/aptly/public',
    port            => '80',
    servername      => 'aptly.publiq.be',
    redirect_source => '/',
    redirect_dest   => 'http://localhost:80',
    redirect_status => 'permanent',
  }
}
