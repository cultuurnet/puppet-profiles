class profiles::python (
  Boolean $with_dev = false
) inherits ::profiles {

  if $facts['python_version'] {
    $python_release = join(split($facts['python_version'], /\./)[0,2], '.')

    @profiles::jenkins::node_labels { 'python':
      content => "python${python_release}"
    }
  }

  if $with_dev {
    package { 'python3-pip':
      ensure => 'installed'
    }
  }

  package { 'python3':
    ensure => 'installed'
  }
}
