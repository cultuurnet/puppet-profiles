class profiles::apache::metrics (
  String $endpoint = '/server-status'
) inherits ::profiles {

  $status_url = "http://127.0.0.1/${regsubst($endpoint, '^/', '')}?auto"

  include profiles::apache
  include profiles::collectd

  class { 'apache::mod::status':
    requires    => 'ip 127.0.0.1',
    status_path => "/${regsubst($endpoint, '^/', '')}"
  }

  class { 'collectd::plugin::apache':
    instances => { 'localhost' => { 'url' => $status_url } }
  }
}
