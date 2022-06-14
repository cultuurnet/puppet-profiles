class profiles::newrelic_infra (
  String $license_key,
  Optional[Variant[Hash]] $integrations = undef,
  Boolean $manage_repo = false
) {

  realize Apt::Source['newrelic-infra']

  class { 'newrelic_infra::agent':
    ensure      => 'latest',
    license_key => $license_key,
    manage_repo => $manage_repo
  }

  if $integrations {
    class { 'newrelic_infra::integrations':
      integrations => $integrations
    }

    if $integrations['newrelic-infra-integretions'] {
      notice("TODO: deploy infra config files")
    }

    if $integrations['nri-mysql'] {
      notice("TODO: deploy mysql config files")
    }

    if $integrations['nri-redis'] {
      notice("TODO: deploy redis config files")
    }

    if $integrations['nri-cassandra'] {
      notice("TODO: deploy cassandra config files")
    }

    if $integrations['nri-apache'] {
      notice("TODO: deploy apache config files")
    }

    if $integrations['nri-nginx'] {
      notice("TODO: deploy nginx config files")
    }
  }
}
