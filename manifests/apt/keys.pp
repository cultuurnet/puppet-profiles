class profiles::apt::keys {

  apt::key { 'Infra CultuurNet':
    id     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
    server => 'keyserver.ubuntu.com',
    source => 'https://apt.publiq.be/gpgkey/cultuurnet.gpg.key'
  }

  apt::key { 'publiq Infrastructure':
    id     => 'AD726BD2A48017B060AA43FA4A49242DE36CDCAF',
    server => 'keyserver.ubuntu.com',
    source => 'https://apt.publiq.be/gpgkey/publiq.gpg.key'
  }

  @apt::key { 'aptly':
    id     => '26DA9D8630302E0B86A7A2CBED75B5A4483DA07C',
    server => 'keyserver.ubuntu.com',
    source => 'https://www.aptly.info/pubkey.txt'
  }

  @apt::key { 'Ubuntu archive':
    id     => '790BC7277767219C42C86F933B4FE6ACC0B21F32',
    server => 'keyserver.ubuntu.com'
  }

  @apt::key { 'docker':
    id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    server => 'keyserver.ubuntu.com',
    source => 'https://download.docker.com/linux/ubuntu/gpg'
  }
}
