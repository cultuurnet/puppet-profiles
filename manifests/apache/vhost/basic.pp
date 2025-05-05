define profiles::apache::vhost::basic (
  Variant[String, Array[String]] $serveraliases       = [],
  String                         $documentroot        = '/var/www/html',
  String                         $access_log_format   = 'extended_json',
  Optional[String]               $certificate         = undef,
  Variant[Hash, Array[Hash]]     $directories         = [],
  Boolean                        $auth_openid_connect = false
) {

  include ::profiles
  include ::profiles::firewall::rules
  include ::profiles::apache
  include ::profiles::certificates

  unless $title =~ Stdlib::Httpurl {
    fail("Defined resource type Profiles::Apache::Vhost::Basic[${title}] expects the title to be a valid HTTP URL")
  }

  $transport  = split($title, ':')[0]
  $servername = split($title, '/')[-1]

  $default_directories = [{ 'path' => $documentroot } + $profiles::apache::defaults::directories]

  if $transport == 'https' {
    unless $certificate {
      fail("Defined resource type Profiles::Apache::Vhost::Basic[${title}] expects a value for parameter certificate when using HTTPS")
    }

    $https    = true
    $port     = 443
    $ssl_cert = "/etc/ssl/certs/${certificate}.bundle.crt"
    $ssl_key  = "/etc/ssl/private/${certificate}.key"

    realize Profiles::Certificate[$certificate]
    realize Firewall['300 accept HTTPS traffic']

    Profiles::Certificate[$certificate] -> Apache::Vhost["${servername}_${port}"]
    Profiles::Certificate[$certificate] ~> Class['apache::service']
  } else {
    $https    = false
    $port     = 80
    $ssl_cert = undef
    $ssl_key  = undef

    realize Firewall['300 accept HTTP traffic']
  }

  if $auth_openid_connect {
    include apache::mod::authn_core

    $openid_connect_directories = [{
                                    'path'      => '/',
                                    'provider'  => 'location',
                                    'auth_type' => 'openid-connect',
                                    'require'   => 'valid-user'
                                  }]
    $openid_connect_settings    = {
                                    'ProviderMetadataURL' => lookup('data::openid::provider_metadata_url', Optional[String], 'first', undef),
                                    'ClientID'            => lookup('data::openid::client_id', Optional[String], 'first', undef),
                                    'ClientSecret'        => lookup('data::openid::client_secret', Optional[String], 'first', undef),
                                    'RedirectURI'         => "https://${servername}/redirect_uri",
                                    'CryptoPassphrase'    => fqdn_rand_string(32)
                                  }
  } else {
    $openid_connect_directories = []
    $openid_connect_settings    = undef
  }

  apache::vhost { "${servername}_${port}":
    servername         => $servername,
    serveraliases      => $serveraliases,
    port               => $port,
    ssl                => $https,
    ssl_cert           => $ssl_cert,
    ssl_key            => $ssl_key,
    docroot            => $documentroot,
    manage_docroot     => false,
    auth_oidc          => $auth_openid_connect,
    oidc_settings      => $openid_connect_settings,
    request_headers    => $profiles::apache::defaults::request_headers + [
                            "setifempty X-Forwarded-Port \"${port}\"",
                            "setifempty X-Forwarded-Proto \"${transport}\""
                          ],
    access_log_format  => $access_log_format,
    access_log_env_var => '!nolog',
    setenvif           => $profiles::apache::defaults::setenvif,
    directories        => $openid_connect_directories + $default_directories + [$directories].flatten
  }
}
