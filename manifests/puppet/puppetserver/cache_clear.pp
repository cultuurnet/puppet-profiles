class profiles::puppet::puppetserver::cache_clear (
  Optional[String] $puppetserver_url = lookup('data::puppet::puppetserver::url', Optional[String], 'first', undef)
) inherits ::profiles {

  $certificate_filename = "/etc/puppetlabs/puppet/ssl/certs/${trusted['certname']}.pem"
  $private_key_filename = "/etc/puppetlabs/puppet/ssl/private_keys/${trusted['certname']}.pem"
  $cacert_filename      = "/etc/puppetlabs/puppet/ssl/certs/ca.pem"

  if $puppetserver_url {
    exec { 'puppetserver_environment_cache_clear':
      command     => "curl -i --cert ${certificate_filename} --key ${private_key_filename} --cacert ${cacert_filename} --fail -X DELETE ${puppetserver_url}/puppet-admin-api/v1/environment-cache",
      path        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
      refreshonly => true
    }
  }
}
