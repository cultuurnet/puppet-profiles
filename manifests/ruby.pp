class profiles::ruby (
  Boolean $with_dev = false
) inherits ::profiles {

  if $with_dev {
    realize Package['bundler']
    realize Package['git']

    package { 'ri':         ensure => 'present' }
    package { 'ruby-dev':   ensure => 'present' }
    package { 'libffi-dev': ensure => 'present' }

    Package['ruby'] -> Package['bundler']
  }

  package { 'ruby':
    ensure => 'present'
  }

  @profiles::jenkins::node_labels { 'ruby':
    content => $facts['os']['distro']['codename'] ? {
                 'focal' => 'ruby2.7',
                 'noble' => 'ruby3.2'
               }
  }
}
