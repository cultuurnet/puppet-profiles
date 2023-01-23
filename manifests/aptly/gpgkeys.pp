class profiles::aptly::gpgkeys {

  @profiles::aptly::gpgkey { 'aptly':
    key_id     => '78D6517AB92E22947F577996A0546A43624A8331',
    key_source => 'https://www.aptly.info/pubkey.txt'
  }

  @profiles::aptly::gpgkey { 'Ubuntu archive':
    key_id     => '790BC7277767219C42C86F933B4FE6ACC0B21F32',
    key_server => 'hkp://keyserver.ubuntu.com'
  }

  @profiles::aptly::gpgkey { 'docker':
    key_id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    key_source => 'https://download.docker.com/linux/ubuntu/gpg'
  }

  @profiles::aptly::gpgkey { 'newrelic':
    key_id     => 'B60A3EC9BC013B9C23790EC8B31B29E5548C16BF',
    key_source => 'https://download.newrelic.com/548C16BF.gpg'
  }

  @profiles::aptly::gpgkey { 'newrelic-infra':
    key_id     => 'A758B3FBCD43BE8D123A3476BB29EE038ECCE87C',
    key_source => 'https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg'
  }

  @profiles::aptly::gpgkey { 'elasticsearch':
    key_id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
    key_source => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  }

  @profiles::aptly::gpgkey { 'nodejs':
    key_id     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
    key_source => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
  }
}
