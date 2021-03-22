class profiles::puppetdb::cli(
  Variant[String, Array[String]] $server_urls
) {

  contain profiles

  include ::profiles::apt::updates

  realize Profiles::Apt::Update['cultuurnet-tools']

  $puppet_agent_ssldir = '/etc/puppetlabs/puppet/ssl'

  package { 'rubygem-puppetdb-cli':
    require => Profiles::Apt::Update['cultuurnet-tools']
  }

  file { '/etc/puppetlabs/client-tools':
    ensure  => 'directory',
  }

  file { 'puppetdb-cli-config':
    ensure  => 'file',
    path    => '/etc/puppetlabs/client-tools/puppetdb.conf',
    content => template('profiles/puppetdb/cli.conf.erb')
  }
}
