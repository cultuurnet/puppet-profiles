define profiles::apt::update {

  include ::profiles

  contain ::profiles::apt::repositories

  realize Apt::Source[$title]

  exec { "apt-get update ${title}":
    command   => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/${title}.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
    path      => [ '/usr/local/bin', '/usr/bin'],
    logoutput => 'on_failure',
    require   => Apt::Source[$title]
  }
}
