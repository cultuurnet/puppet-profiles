define profiles::puppetdb::cli::config (
  Variant[String,Array[String]] $server_urls,
  Optional[String]              $certificate = undef,
  Optional[String]              $private_key = undef
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

  $ssl_dir = "${config_rootdir}/puppet/ssl"

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
        owner  => $title
      }
    }

    file { "${config_rootdir}/puppet/ssl/certs/ca.pem":
      ensure => 'file',
      owner  => $title,
      source => '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
    }

    file { "${config_rootdir}/puppet/ssl/certs/puppetdb-cli.crt":
      ensure  => 'file',
      owner   => $title,
      content => $certificate
    }

    file { "${config_rootdir}/puppet/ssl/private_keys/puppetdb-cli.key":
      ensure  => 'file',
      owner   => $title,
      content => $private_key
    }
  }

  file { "${config_rootdir}/client-tools":
    ensure => 'directory',
    owner  => $title
  }

  file { "puppetdb-cli-config ${title}":
    ensure  => 'file',
    owner   => $title,
    path    => "${config_rootdir}/client-tools/puppetdb.conf",
    content => template('profiles/puppetdb/cli.conf.erb')
  }
}
