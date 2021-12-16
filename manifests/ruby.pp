class profiles::ruby (
  Boolean $with_dev = false
) inherits ::profiles {

  include ::profiles::packages

  if $with_dev {
    realize Package['bundler']
    realize Package['git']

    package { 'ri':         ensure => 'present'}
    package { 'ruby-dev':   ensure => 'present'}
    package { 'libffi-dev': ensure => 'present'}

    Package['ruby'] -> Package['bundler']
  }

  package { 'ruby':
    ensure => 'present'
  }
}
