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


  if $initial_size {
    jvmoption { "Domain ${title} initial heap jvmoption":
      ensure => 'present',
      option => "-Xms${initial_size}",
      before => File["Domain ${title} heap external facts"],
      *      => $jvmoption_default_attributes
    }

    if fact("glassfish.$title.heap.initial_size") {
      if !($initial_size == $facts['glassfish'][$title]['heap']['initial_size']) {
        jvmoption { "Domain ${title} previous initial heap jvmoption removal":
          ensure => 'absent',
          option => "-Xms${facts['glassfish'][$title]['heap']['initial_size']}",
          before => [Jvmoption["Domain ${title} initial heap jvmoption"], File["Domain ${title} heap external facts"]],
          *      => $jvmoption_default_attributes
        }
      }
    }
  } else {
    if fact("glassfish.$title.heap.initial_size") {
      jvmoption { "Domain ${title} previous initial heap jvmoption removal":
        ensure => 'absent',
        option => "-Xms${facts['glassfish'][$title]['heap']['initial_size']}",
        before => File["Domain ${title} heap external facts"],
        *      => $jvmoption_default_attributes
      }
    }
  }

  if $maximum_size {
    jvmoption { "Domain ${title} maximum heap jvmoption":
      ensure => 'present',
      option => "-Xmx${maximum_size}",
      before => File["Domain ${title} heap external facts"],
      *      => $jvmoption_default_attributes
    }

    if fact("glassfish.$title.heap.maximum_size") {
      if !($maximum_size == $facts['glassfish'][$title]['heap']['maximum_size']) {
        jvmoption { "Domain ${title} previous maximum heap jvmoption removal":
          ensure => 'absent',
          option => "-Xmx${facts['glassfish'][$title]['heap']['maximum_size']}",
          before => [Jvmoption["Domain ${title} maximum heap jvmoption"], File["Domain ${title} heap external facts"]],
          *      => $jvmoption_default_attributes
        }
      }
    } else {
      if !($maximum_size == $default_maximum_size) {
        jvmoption { "Domain ${title} previous maximum heap jvmoption removal":
          ensure => 'absent',
          option => "-Xmx${default_maximum_size}",
          before => [Jvmoption["Domain ${title} maximum heap jvmoption"], File["Domain ${title} heap external facts"]],
          *      => $jvmoption_default_attributes
        }
      }
    }
  } else {
    jvmoption { "Domain ${title} maximum heap jvmoption":
      ensure => 'present',
      option => "-Xmx${default_maximum_size}",
      before => File["Domain ${title} heap external facts"],
      *      => $jvmoption_default_attributes
    }

    if fact("glassfish.$title.heap.maximum_size") {
      if !($default_maximum_size == $facts['glassfish'][$title]['heap']['maximum_size']) {
        jvmoption { "Domain ${title} previous maximum heap jvmoption removal":
          ensure => 'absent',
          option => "-Xmx${facts['glassfish'][$title]['heap']['maximum_size']}",
          before => [Jvmoption["Domain ${title} maximum heap jvmoption"], File["Domain ${title} heap external facts"]],
          *      => $jvmoption_default_attributes
        }
      }
    }
  }

  file { "Domain ${title} heap external facts":
    ensure  => 'file',
    path    => "/etc/puppetlabs/facter/facts.d/glassfish.${title}.heap.yaml",
    content => template('profiles/glassfish/domain/heap.yaml.erb'),
    require => File['/etc/puppetlabs/facter/facts.d']
  }
}
