class profiles::fail2ban inherits ::profiles {

  class { 'fail2ban':
    manage_defaults          => 'present',
    package_ensure           => 'latest',
    service_ensure           => 'running',
    service_enable           => true,
    config_file_hash         => {},
    config_file_options_hash => {},
    email                    => "infra@publiq.be",
    sender                   => "fail2ban@${facts['networking']['fqdn']}",
    whitelist                => ['127.0.0.1/8'],
    jails                    => ['ssh', 'ssh-ddos'],
    custom_jails             => {}
  }
}
