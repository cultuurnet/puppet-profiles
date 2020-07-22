## This profile/module installs and configures aptly.
class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = '',
  $sslchain = '',
  $sslcert = '',
  $sslkey = '',
  $gpgkey_source = '',
  $gpgkey_fingerprint = ''
) {

  contain ::profiles
  $aptly_api_port = 8081  #By defualt the aptly-puppet module sets the api port to 8081, aptly itself defaults to 8080.
  $apache_server = 'aptly.publiq.be'

  # This will install aptly and set the s3_publish_endpoints parameter.
  class { 'aptly':
    install_repo         => true, # Tell aptly to install from a repo
    repo_location        => 'http://repo.aptly.info/', # Where to get the deb file
    repo_keyserver       => 'hkps.pool.sks-keyservers.net', # Where to get the install key
    repo_key             => 'ED75B5A4483DA07C',
    api_nolock           => true,
    enable_api           => true,
    port                 => $aptly_api_port,

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
    docroot             => '/var/www/html',
    manage_docroot      => false,
    port                => '80',
    servername          => $apache_server,
    proxy_preserve_host => true,
    proxy_pass          =>
    {
      path =>  '/',
      url  => "http://localhost:${aptly_api_port}/"
    }
  }

  apache::vhost { 'apt-private_443':
    docroot             => '/var/www/html',
    manage_docroot      => false,
    proxy_preserve_host => true,
    port                => '443',
    servername          => $apache_server,
    ssl                 => true,
    ssl_cert            => $sslcert,
    ssl_chain           => $sslchain,
    ssl_key             => $sslkey,
    proxy_pass          =>
    {
      path =>  '/',
      url  => "http://localhost:${aptly_api_port}/"
    },
    require             => [
      File[$sslchain],
      File[$sslcert],
      File[$sslkey],
    ]
  }

  file { '/home/aptly':
    ensure => 'directory',
    owner  => 'aptly',
    group  => 'aptly',
    mode   => '0755'
  }

  file { '/home/aptly/private.key':
    ensure  => 'file',
    owner   => 'aptly',
    group   => 'aptly',
    mode    => '0644',
    require => File['/home/aptly'],
    source  => $gpgkey_source
  }

  #Install the gpg key for the aptly user to sign the published packages.
  exec { 'import_gpg_secret_key':
    path    => '/home/aptly',
    command => "/usr/bin/gpg --import /home/aptly/private.key",
    unless  => "test ${gpgkey_fingerprint} = $(gpg --list-secret-keys --with-colons --fingerprint | egrep '^fpr' | cut -d : -f 10)",
    user    => 'aptly',
    group   => 'aptly',
    require => File['/home/aptly/private.key']
  }
}
