define profiles::aptly::gpgkey (
  String           $key_id,
  Optional[String] $key_source = undef,
  Optional[String] $key_server = undef
) {

  include ::profiles

  if ($key_source or $key_server) {
    realize Group['aptly']
    realize User['aptly']

    gnupg_key { $title:
      ensure     => 'present',
      key_id     => $key_id[-16,16],
      user       => 'aptly',
      key_source => $key_source,
      key_server => $key_server,
      key_type   => 'public',
      require    => User['aptly']
    }
  } else {
    fail("Profiles::Aptly::Gpgkey[${title}] expects a value for parameter 'key_source' or 'key_server'")
  }
}
