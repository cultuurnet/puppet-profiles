class profiles::fail2ban (
  Enum['absent','present']                      $manage_defaults          = 'present',
  Enum['absent', 'latest', 'present', 'purged'] $package_ensure           = 'latest',
  Enum['running', 'stopped']                    $service_ensure           = 'running',
  Boolean                                       $service_enable           = true,
  Hash[String[1], Any]                          $config_file_hash         = {},
  Hash                                          $config_file_options_hash = {},
  String[1]                                     $email                    = "infra@publiq.be",
  String[1]                                     $sender                   = "fail2ban@${facts['networking']['fqdn']}",
  Array                                         $whitelist                = ['127.0.0.1/8'],
  Array[String[1]]                              $jails                    = ['ssh', 'ssh-ddos'],
  Hash[String, Hash]                            $custom_jails             = {}
) inherits ::profiles {

  class { 'fail2ban':
    manage_defaults          => $manage_defaults         
    package_ensure           => $package_ensure          
    service_ensure           => $service_ensure          
    service_enable           => $service_enable          
    config_file_hash         => $config_file_hash        
    config_file_options_hash => $config_file_options_hash
    email                    => $email                   
    sender                   => $sender                  
    whitelist                => $whitelist               
    jails                    => $jails
    custom_jails             => $custom_jails
  }
}
