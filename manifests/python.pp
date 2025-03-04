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
}
