##  This profile ensures the correct installation and operation of the puppet server.
class profiles::puppet::server {
  contain ::profiles

  realize Apt::Source['publiq-infrastructure']
  realize Profiles::Apt::Update['publiq-infrastructure']

  package{'publiq-infrastructure':
    ensure  => latest,
    require => Profiles::Apt::Update['publiq-infrastructure'],
  }

  # This is only possible because we manually added 'authorization-required: false' in /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf
  # This was done in the puppet-admin block at the end of the file.TODO: When this profile expands we need to puppetize this.
  # The puppet module hocon could be an option. It allows you to manipulate files with a HOCOM format, like puppetserver.conf
  exec{'clean-cache':
    command => ' curl -i -k -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
    path    => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    require => Package['publiq-infrastructure'],
  }
}
