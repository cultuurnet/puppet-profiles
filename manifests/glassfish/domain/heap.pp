define profiles::glassfish::domain::heap (
  Optional[String] $initial_size = undef,
  Optional[String] $maximum_size = undef,
  Integer          $portbase     = 4800
) {

  include ::profiles

  realize File['/etc/puppetlabs/facter/facts.d']

  $default_maximum_size         = '512m'
  $jvmoption_default_attributes = {
    user         => 'glassfish',
    passwordfile => '/home/glassfish/asadmin.pass',
    portbase     => String($portbase)
  }

  #
  # Set initial heap if provided
  #
  if $initial_size {
    jvmoption { "Domain ${title} initial heap jvmoption":
      ensure => 'present',
      option => "-Xms${initial_size}",
      *      => $jvmoption_default_attributes
    }
  }

  # Remove previous initial heap if it differs
  if fact("glassfish.$title.heap.initial_size") {
    if $facts['glassfish'][$title]['heap']['initial_size'] != $initial_size {
      jvmoption { "Domain ${title} previous initial heap jvmoption removal":
        ensure => 'absent',
        option => "-Xms${facts['glassfish'][$title]['heap']['initial_size']}",
        *      => $jvmoption_default_attributes
      }
    }
  }

  #
  # Determine final maximum heap size
  #
  $final_maximum_size = $maximum_size ? {
    undef   => $default_maximum_size,
    default => $maximum_size,
  }

  # Set maximum heap
  jvmoption { "Domain ${title} maximum heap jvmoption":
    ensure => 'present',
    option => "-Xmx${final_maximum_size}",
    *      => $jvmoption_default_attributes
  }

  # Remove previous maximum heap if it differs
  if fact("glassfish.$title.heap.maximum_size") {
    if $facts['glassfish'][$title]['heap']['maximum_size'] != $final_maximum_size {
      jvmoption { "Domain ${title} previous maximum heap jvmoption removal":
        ensure => 'absent',
        option => "-Xmx${facts['glassfish'][$title]['heap']['maximum_size']}",
        *      => $jvmoption_default_attributes
      }
    }
  }

  #
  # Export facts
  #
  file { "Domain ${title} heap external facts":
    ensure  => 'file',
    path    => "/etc/puppetlabs/facter/facts.d/glassfish.${title}.heap.yaml",
    content => template('profiles/glassfish/domain/heap.yaml.erb'),
    require => File['/etc/puppetlabs/facter/facts.d'],
  }

}
