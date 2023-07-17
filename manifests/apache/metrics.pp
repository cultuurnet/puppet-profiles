class profiles::apache::metrics inherits ::profiles {

  include profiles::apache
  include profiles::collectd

  class { 'apache::mod::status':
    requires    => 'ip 127.0.0.1',
    status_path => '/server-status'
  }

  class { 'collectd::plugin::apache':
    instances => { 'localhost' => { 'url' => 'http://127.0.0.1/server-status?auto' } }
  }
}
