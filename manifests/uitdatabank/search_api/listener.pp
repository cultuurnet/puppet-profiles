define profiles::uitdatabank::search_api::listener (
  Enum['present', 'absent'] $ensure  = 'present',
  String                    $basedir = '/var/www/udb3-search-service',
  Optional[String]          $command = undef
) {

  include ::profiles

  systemd::unit_file { "${title}.service":
    ensure  => $ensure,
    content => template('profiles/uitdatabank/search_api/uitdatabank-consume-queue.service.erb')
  }

  if $ensure == 'present' {
    unless $command {
      fail("Defined resource type Profiles::Uitdatabank::Search_api::Listener[${title}] expects a value for parameter 'command'")
    }

    realize Group['www-data']
    realize User['www-data']

    service { $title:
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      require   => [Group['www-data'], User['www-data']],
      subscribe => Systemd::Unit_file["${title}.service"]
    }
  }
}
