class profiles::jenkins::agent (
  Boolean $bootstrap = false
) inherits ::profiles {

  include profiles::jenkins::node
  include profiles::jenkins::buildtools::bootstrap

  unless $bootstrap {

    include profiles::jenkins::buildtools::extra
    include profiles::jenkins::buildtools::playwright

    profiles::puppet::puppetdb::cli { 'jenkins': }

    file { 'node-cleanup-script':
      ensure  => 'file',
      path    => '/usr/local/bin/node-cleanup.sh',
      mode    => '0755',
      content => template('profiles/jenkins/node-cleanup-script.erb')
    }

    @@profiles::vault::trusted_certificate { $trusted['certname']:
      policies => ['jenkins_certificate']
    }
  }
}
