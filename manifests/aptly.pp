class profiles::aptly (
  $awsaccesskeyid = '',
  $awssecretaccesskey = '',
  $sslchain = '',
  $sslcert = '',
  $sslkey = '',
  $gpgkey_source = '',
  $gpgkey_fingerprint = '',
  $data_dir = '/var/aptly',
  $repositories = []
) {

  contain ::profiles

  $aptly_api_port = 8081  #By defualt the aptly-puppet module sets the api port to 8081, aptly itself defaults to 8080.
  $virtual_host   = 'aptly.publiq.be'

  realize Profiles::Apt::Update['aptly']

  class { 'aptly':
    install_repo         => false,
    root_dir             => $data_dir,
    enable_service       => false,
    enable_api           => true,
    api_nolock           => true,
    port                 => $aptly_api_port,
    require              => Profiles::Apt::Update['aptly'],
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

  class { 'apache':
    default_vhost => false,
  }

  package { 'graphviz':
    ensure => 'present'
  }

  apache::vhost { "${virtual_host}_80":
    docroot         => '/var/www/html',
    manage_docroot  => false,
    port            => '80',
    servername      => $virtual_host,
    redirect_source => '/',
    redirect_dest   => "https://${virtual_host}",
    redirect_status => 'permanent'
  }

  apache::vhost { "${virtual_host}_443":
    docroot             => '/var/www/html',
    manage_docroot      => false,
    proxy_preserve_host => true,
    port                => '443',
    servername          => $virtual_host,
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
    command => 'gpg --import /home/aptly/private.key',
    path    => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    unless  => "test ${gpgkey_fingerprint} = $(gpg --list-secret-keys --with-colons --fingerprint | egrep '^fpr' | cut -d : -f 10)",
    user    => 'aptly',
    group   => 'aptly',
    require => File['/home/aptly/private.key']
  }

  any2array($repositories).each |$repo| {
    aptly::repo { $repo:
      ensure            => 'present',
      default_component => 'main'
    }
  }
}
