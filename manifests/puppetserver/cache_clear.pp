class profiles::puppetserver::cache_clear inherits ::profiles {

  exec { 'puppetserver_environment_cache_clear':
    command     => 'curl -i -k --fail -X DELETE https://localhost:8140/puppet-admin-api/v1/environment-cache',
    path        => [ '/usr/local/bin', '/usr/bin', '/bin' ],
    refreshonly => true
  }
}
