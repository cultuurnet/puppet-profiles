define profiles::puppet::puppetdb::cli::config (
  Optional[String]                        $certificate_name = undef,
  Optional[Variant[String,Array[String]]] $server_urls      = lookup('data::puppet::puppetdb::url', Optional[String], 'first', undef)
) {

  include ::profiles

  unless $server_urls {
    fail("Defined resource type Profiles::Puppet::Pupppetdb::Cli::Config[${title}] expects a value for parameter 'server_urls'")
  }

  $default_file_attributes = {
                               owner   => $title,
                               group   => $title
                             }

  case $title {
    'root':     {
                  $config_rootdir = '/root/.puppetlabs'
                }
    'jenkins':  {
                  $config_rootdir = "/var/lib/${title}/.puppetlabs"

                  realize Group['jenkins']
                  realize User['jenkins']
                }
    'www-data': {
                  $config_rootdir = '/var/www/.puppetlabs'

                  realize Group['www-data']
                  realize User['www-data']
                }
    default:    {
                  $config_rootdir = "/home/${title}/.puppetlabs"
                }
  }

  file { [$config_rootdir, "${config_rootdir}/puppet", "${config_rootdir}/puppet/ssl", "${config_rootdir}/puppet/ssl/certs", "${config_rootdir}/puppet/ssl/private_keys"]:
    ensure  => 'directory',
    *       => $default_file_attributes
  }

  if $certificate_name {
    $certificate_filename = "${certificate_name}.pem"
    $private_key_filename = "${certificate_name}.pem"

    puppet_certificate { $certificate_name:
      ensure      => 'present',
      waitforcert => 60,
      before      => [File["${config_rootdir}/puppet/ssl/certs/${certificate_filename}"], File["${config_rootdir}/puppet/ssl/private_keys/${private_key_filename}"]]
    }
  } else {
    $certificate_filename = "${trusted['certname']}.pem"
    $private_key_filename = "${trusted['certname']}.pem"
  }

  file { "${config_rootdir}/puppet/ssl/certs/${certificate_filename}":
    ensure  => 'file',
    source  => "file:///etc/puppetlabs/puppet/ssl/certs/${certificate_filename}",
    *       => $default_file_attributes
  }

  file { "${config_rootdir}/puppet/ssl/private_keys/${private_key_filename}":
    ensure  => 'file',
    mode    => '0400',
    source  => "file:///etc/puppetlabs/puppet/ssl/private_keys/${private_key_filename}",
    *       => $default_file_attributes
  }

  file { "${config_rootdir}/puppet/ssl/certs/ca.pem":
    ensure => 'file',
    source => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem',
    *      => $default_file_attributes
  }

  file { "${config_rootdir}/client-tools":
    ensure => 'directory',
    *      => $default_file_attributes
  }

  file { "puppetdb-cli-config ${title}":
    ensure  => 'file',
    path    => "${config_rootdir}/client-tools/puppetdb.conf",
    content => template('profiles/puppet/puppetdb/cli.conf.erb'),
    *       => $default_file_attributes
  }
}
