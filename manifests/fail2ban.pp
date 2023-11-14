# The default values in this profile configure fail2ban to check /var/log/auth.log for failed ssh login attempts
# An email with banned ip's will be sent out on a regular basis (action_mb)
# To disable sending of emails use action = 'action_'
# See /etc/fail2ban/jail.conf for more possible actions
#
# Usage example:
#
# ---
# classes:
#   - include profile::fail2ban
#
# profiles::fail2ban::action: 'action_'
#
class profiles::fail2ban(
  String                         $action                   = 'action_mb',
  String                         $email                    = 'infra@publiq.be',
  String                         $sender                   = "fail2ban@${facts['networking']['fqdn']}",
  Variant[String, Array[String]] $whitelist                = ['127.0.0.1/8'],
  Variant[String, Array[String]] $jails                    = ['ssh', 'ssh-ddos'],
  Hash                           $config_file_hash         = {},
  Hash                           $config_file_options_hash = {},
  Hash                           $custom_jails             = {}
) inherits ::profiles {

  class { 'fail2ban':
    manage_defaults          => 'present',
    package_ensure           => 'latest',
    service_ensure           => 'running',
    service_enable           => true,
    action                   => $action,
    email                    => $email,
    sender                   => $sender,
    whitelist                => [$whitelist].flatten,
    jails                    => [$jails].flatten,
    config_file_hash         => $config_file_hash,
    config_file_options_hash => $config_file_options_hash,
    custom_jails             => $custom_jails
  }
}
