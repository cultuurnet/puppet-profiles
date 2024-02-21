define profiles::puppet::puppetdb::cli::config (
  Variant[String,Array[String]] $server_urls,
  Optional[String]              $certificate    = undef,
  Optional[String]              $private_key    = undef,
  Optional[String]              $ca_certificate = undef
) {

  include ::profiles

  case $title {
    'root':    {
                 if ($certificate and $private_key) {
                   $config_rootdir       = '/root/.puppetlabs'
                   $certificate_filename = 'puppetdb-cli.crt'
                   $private_key_filename = 'puppetdb-cli.key'
                 } else {
                   $config_rootdir = '/etc/puppetlabs'
                   $certificate_filename = "${trusted['certname']}.pem"
                   $private_key_filename = "${trusted['certname']}.pem"
                 }
               }
    'jenkins': {
                 if ($certificate and $private_key) {
                   $config_rootdir = "/var/lib/${title}/.puppetlabs"
                   $certificate_filename = 'puppetdb-cli.crt'
                   $private_key_filename = 'puppetdb-cli.key'
                 } else {
                   fail("Profiles::Puppetdb::Cli::Config[${title}] expects a value for parameters 'certificate' and 'private_key'")
                 }

                 realize Group['jenkins']
                 realize User['jenkins']
               }
    'www-data': {
                 if ($certificate and $private_key) {
                   $config_rootdir = '/var/www/.puppetlabs'
                   $certificate_filename = 'puppetdb-cli.crt'
                   $private_key_filename = 'puppetdb-cli.key'
                 } else {
                   fail("Profiles::Puppetdb::Cli::Config[${title}] expects a value for parameters 'certificate' and 'private_key'")
                 }

                 realize Group['www-data']
                 realize User['www-data']
               }
    default:   {
                 if ($certificate and $private_key) {
                   $config_rootdir = "/home/${title}/.puppetlabs"
                   $certificate_filename = 'puppetdb-cli.crt'
                   $private_key_filename = 'puppetdb-cli.key'
                 } else {
                   fail("Profiles::Puppetdb::Cli::Config[${title}] expects a value for parameters 'certificate' and 'private_key'")
                 }
               }
  }

  $ssl_dir                 = "${config_rootdir}/puppet/ssl"
  $default_file_attributes = {
                               owner => $title,
                               group => $title
                             }

  if ($certificate and $private_key) {
    [
      $config_rootdir,
      "${config_rootdir}/puppet",
      "${config_rootdir}/puppet/ssl",
      "${config_rootdir}/puppet/ssl/certs",
      "${config_rootdir}/puppet/ssl/private_keys"
    ].each |$directory| {
      file { $directory:
        ensure => 'directory',
        *      => $default_file_attributes
      }
    }

    file { "${ssl_dir}/certs/puppetdb-cli.crt":
      ensure  => 'file',
      content => $certificate,
      *       => $default_file_attributes
    }

    file { "${ssl_dir}/private_keys/puppetdb-cli.key":
      ensure  => 'file',
      mode    => '0400',
      content => $private_key,
      *       => $default_file_attributes
    }
  }

  if $ca_certificate {
    file { "${ssl_dir}/certs/ca.pem":
      ensure  => 'file',
      content => $ca_certificate,
      *       => $default_file_attributes
    }
  } else {
    file { "${ssl_dir}/certs/ca.pem":
      ensure => 'file',
      source => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      *      => $default_file_attributes
    }
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
