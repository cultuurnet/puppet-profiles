class profiles::uitpas::soap (

  Boolean $deployment            = true,
  Boolean $magda_cert_generation = false,
  Boolean $fidus_cert_generation = false,
  Hash $env_settings             = {},
  String $repository             = 'uitpas-soap',

) inherits profiles {
  include profiles::java

  if ($magda_cert_generation) {
    include profiles::uitpas::soap::magda

    if ($deployment) {
      Class['profiles::uitpas::soap::magda'] ~> Class['profiles::uitpas::soap::deployment']
    }
  }
  if ($fidus_cert_generation) {
    include profiles::uitpas::soap::fidus

    if ($deployment) {
      Class['profiles::uitpas::soap::fidus'] ~> Class['profiles::uitpas::soap::deployment']
    }
  }
  file { '/opt/uitpas-soap/env.properties':
    ensure   => 'file',
    content  => template('profiles/uitpas/soap/env.properties.erb', { 'settings' => $env_settings }),
    owner    => 'glassfish',
    group    => 'glassfish',
    mode     => '0644',
  }
  realize Apt::Source[$repository]

  if ($deployment) {
    include profiles::uitpas::soap::deployment
  }
}
