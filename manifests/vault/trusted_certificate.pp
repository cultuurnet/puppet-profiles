define profiles::vault::trusted_certificate (
  String                         $trusted_certs_directory = '/etc/vault.d/trusted_certs',
  Variant[String, Array[String]] $policies                = 'puppet_certificate',
  Optional[String]               $certificate             = undef
) {

  include ::profiles

  $policies_string = [$policies].flatten.join(',')

  realize Group['vault']
  realize User['vault']

  file { "vault trusted cert ${title}":
    ensure  => 'file',
    path    => "${trusted_certs_directory}/${title}.pem",
    owner   => 'vault',
    group   => 'vault',
    content => $certificate ? {
                 undef   => file("/etc/puppetlabs/puppet/ssl/certs/${title}.pem"),
                 default => $certificate
               },
    require => [Group['vault'], User['vault']]
  }

  exec { "vault_trust_cert ${title}":
    command   => "/usr/bin/vault write auth/cert/certs/${title} display_name=${title} policies=${policies_string} certificate=@${trusted_certs_directory}/${title}.pem",
    user      => 'vault',
    unless    => "/usr/bin/vault read auth/cert/certs/${title}",
    logoutput => 'on_failure',
    require   => [User['vault'], File["vault trusted cert ${title}"]]
  }
}
