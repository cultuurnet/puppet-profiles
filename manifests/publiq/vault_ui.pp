class profiles::publiq::vault_ui (
  String $certname
) inherits ::profiles {

  realize File['/etc/puppetlabs/facter/facts.d']

  puppet_certificate { $certname:
    ensure               => 'present',
    waitforcert          => 60,
    renewal_grace_period => 5,
    clean                => true
  }

  file { 'vault_ui_certificate_external_fact':
    ensure  => 'file',
    path    => '/etc/puppetlabs/facter/facts.d/vault_ui_certificate.txt',
    content => 'vault_ui_certificate_available=true',
    require => [File['/etc/puppetlabs/facter/facts.d'], Puppet_certificate[$certname]]
  }

  if $facts['vault_ui_certificate_available'] {
    @@profiles::vault::trusted_certificate { $certname:
      policies => ['puppet_certificate', 'ui_certificate']
    }
  }
}
