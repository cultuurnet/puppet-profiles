class profiles::uitid::reverse_proxy (
  String $servername,
  Optional[String]              $certificate                = 'wildcard.uitid.be',
  String                        $config_source              = undef,
  String                        $originalhost_config_source = undef,
  String                        $ssl_config_source          = undef,
  Variant[String,Array[String]] $serveraliases              = [],
  Hash $settings                                            = {}

) inherits profiles {
  include nginx

  $basedir = '/etc/nginx'

  realize Profiles::Certificate[$certificate]
  realize Firewall['300 accept HTTPS traffic']

  file { 'nginx-config':
    ensure => file,
    path   => "${basedir}/sites-available/uitid-proxy.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $config_source,
    notify => Service['nginx'],
  }

  file { 'ssl-uitpas':
    ensure => file,
    path   => "${basedir}/conf.d/ssl_uitpas.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $ssl_config_source,
    notify => Service['nginx'],
  }
  file { 'originalhost-uitpas':
    ensure => file,
    path   => "${basedir}/conf.d/originalhost.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $originalhost_config_source,
    notify => Service['nginx'],
  }
  file { 'nginx-config-link':
    ensure => link,
    path   => "${basedir}sites-enabled/uitid-proxy.conf",
    target => "${basedir}sites-available/uitid-proxy.conf",
  }
}
