class profiles::apt::keys {

  apt::key { 'Infra CultuurNet':
    id     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
    source => 'https://apt.publiq.be/gpgkey/cultuurnet.gpg.key'
  }

  apt::key { 'publiq Infrastructure':
    id     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
    source => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
  }

  @apt::key { 'aptly':
    id     => '78D6517AB92E22947F577996A0546A43624A8331',
    source => 'https://www.aptly.info/pubkey.txt'
  }
}
