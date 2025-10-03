class profiles::publiq::mailpit (
  String                         $servername,
  Variant[String, Array[String]] $serveraliases = []
) inherits ::profiles {

  include ::profiles::apache

  class { 'profiles::mailpit':
    smtp_address => '0.0.0.0'
  }

  profiles::apache::vhost::reverse_proxy { "http://${servername}":
    aliases             => $serveraliases,
    destination         => 'http://127.0.0.1:8025/',
    auth_openid_connect => true,
    require             => Class['profiles::mailpit']
  }
}
