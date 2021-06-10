class profiles::apt::keys {

  contain ::profiles

  apt::key { 'aptly':
    id     => '26DA9D8630302E0B86A7A2CBED75B5A4483DA07C',
    source => 'https://www.aptly.info/pubkey.txt'
  }

  apt::key { 'Infra CultuurNet':
    id     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
    server => 'https://dummy.key.server',
    source => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
  }

  apt::key { 'publiq Infrastructure':
    id     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
    server => 'https://dummy.key.server',
    source => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
  }
}
