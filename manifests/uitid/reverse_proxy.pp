class profiles::uitid::reverse_proxy (
  String $servername,
  Optional[String]              $certificate                = 'wildcard.uitid.be',
  String                        $config_source              = undef,
  String                        $originalhost_config_source = undef,
  String                        $ssl_config_source          = undef,
  Boolean                       $gcloud_etl_sync_enabled    = true,

) inherits profiles {
  include nginx

  $basedir = '/etc/nginx'

  realize Profiles::Certificate[$certificate]
  realize Firewall['300 accept HTTPS traffic']
  realize Firewall['300 accept HTTP traffic']

  if $gcloud_etl_sync_enabled {
    $secrets = lookup('vault:uitid/reverseproxy')

    profiles::google::gcloud { 'root':
      credentials => {
        project_id     => $secrets['gcloud_project_id'],
        private_key_id => $secrets['gcloud_private_key_id'],
        private_key    => $secrets['gcloud_private_key'],
        client_id      => $secrets['gcloud_client_id'],
        client_email   => $secrets['gcloud_client_email'],
      },
    }
  }

  file { 'nginx-config':
    ensure => file,
    path   => "${basedir}/sites-available/uitid-proxy.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $config_source,
    notify => Service['nginx'],
  }

  file { 'ssl-uitpas':
    ensure => file,
    path   => "${basedir}/conf.d/ssl_uitpas.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $ssl_config_source,
    notify => Service['nginx'],
  }
  file { 'originalhost-uitpas':
    ensure => file,
    path   => "${basedir}/conf.d/originalhost.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => $originalhost_config_source,
    notify => Service['nginx'],
  }
  file { 'nginx-config-link':
    ensure => link,
    path   => "${basedir}/sites-enabled/uitid-proxy.conf",
    target => "${basedir}/sites-available/uitid-proxy.conf",
  }

  if $gcloud_etl_sync_enabled {
    cron { 'gsutil_rsync_nginx_logs':
      ensure      => present,
      environment => ['MAILTO=infra+cron@publiq.be'],
      command     => '/usr/bin/gsutil rsync -x ".*error.*|.*log$|uitpas-prod.uitid.*|^access.log.*" /var/log/nginx/ gs://publiq-etl-prod/etl/rev_proxy_logs/raw/',
      user        => 'root',
      minute      => 45,
      hour        => 7,
    }
  }
}
