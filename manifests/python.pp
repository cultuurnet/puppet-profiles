class profiles::python (
  Boolean $with_dev = false
) inherits ::profiles {

  if $with_dev {
    package { 'python3-pip':
      ensure => 'installed'
    }
  }

  package { 'python3':
    ensure => 'installed'
  }

  @profiles::jenkins::node_labels { 'python':
    content => $facts['os']['distro']['codename'] ? {
                 'focal' => 'python3.8',
                 'noble' => 'python3.12'
               }
  }
}
