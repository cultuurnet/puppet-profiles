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
class profiles::fail2ban inherits ::profiles {

  class { 'fail2ban':
    manage_defaults          => 'present',
    package_ensure           => 'latest',
    service_ensure           => 'running',
    service_enable           => true,
    config_file_hash         => {},
    config_file_options_hash => {},
    action                   => 'action_mb',
    email                    => "infra@publiq.be",
    sender                   => "fail2ban@${facts['networking']['fqdn']}",
    whitelist                => ['127.0.0.1/8'],
    jails                    => ['ssh', 'ssh-ddos'],
    custom_jails             => {}
  }
}
