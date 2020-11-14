class profiles::apt::keys {

  contain ::profiles

  apt::key { 'Infra CultuurNet':
    id     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
    server => 'keyserver.ubuntu.com',
    source => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
  }

  apt::key { 'publiq Infrastructure':
    id     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
    server => 'keyserver.ubuntu.com',
    source => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
  }
}
