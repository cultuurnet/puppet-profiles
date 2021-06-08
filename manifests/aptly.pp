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

  include ::profiles::users
  include ::profiles::groups

  $api_bind = '127.0.0.1'
  $api_port = 8081
  $hostname = 'aptly.publiq.be'

  realize Group['aptly']
  realize User['aptly']

  realize Profiles::Apt::Update['aptly']

  class { 'aptly':
    install_repo         => false,
    manage_user          => false,
    root_dir             => $data_dir,
    enable_service       => false,
    enable_api           => true,
    api_bind             => $api_bind,
    api_port             => $api_port,
    api_nolock           => true,
    require              => [ Profiles::Apt::Update['aptly'], User['aptly']],
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

  if versioncmp( $facts['os']['major']['release'], '16.04') >= 0 {
    systemd::unit_file { 'aptly-api.service':
      content => template('profiles/aptly/aptly-api.service.erb'),
      enable  => true,
      active  => true
    }
  }

  class { 'apache':
    default_vhost => false
  }

  package { 'graphviz':
    ensure => 'present'
  }

  apache::vhost { "${hostname}_80":
    docroot         => '/var/www/html',
    manage_docroot  => false,
    port            => '80',
    servername      => $hostname,
    redirect_source => '/',
    redirect_dest   => "https://${hostname}",
    redirect_status => 'permanent'
  }

  apache::vhost { "${hostname}_443":
    docroot             => '/var/www/html',
    manage_docroot      => false,
    proxy_preserve_host => true,
    port                => '443',
    servername          => $hostname,
    ssl                 => true,
    ssl_cert            => $sslcert,
    ssl_chain           => $sslchain,
    ssl_key             => $sslkey,
    proxy_pass          =>
    {
      path =>  '/',
      url  => "http://${api_bind}:${api_port}/"
    },
    require             => [
      File[$sslchain],
      File[$sslcert],
      File[$sslkey],
    ]
  }

  file { '/home/aptly/private.key':
    ensure  => 'file',
    owner   => 'aptly',
    group   => 'aptly',
    mode    => '0644',
    require => User['aptly'],
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
