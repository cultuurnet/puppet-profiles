class profiles::apache::logging (
  Integer $retention_days = 21
) inherits ::profiles {

  include profiles::logrotate

  # delaycompress is off (to save disk space), so the just-rotated file is compressed immediately
  # by gzip, which unlinks its plain source once done. If some apache2 worker
  # hasn't yet reopened its log handle (e.g. it was idle, not mid-request, at
  # reload time) it can still be writing to that now-deleted file. lsof finds
  # and kills any such worker so apache2 respawns one with a fresh handle.
  package { 'lsof':
    ensure => installed,
  }

  logrotate::rule { 'apache2':
    path          => '/var/log/apache2/*.log',
    rotate        => $retention_days - 1,
    delaycompress => false,
    create_owner  => 'root',
    create_group  => 'adm',
    postrotate    => [
      'systemctl status apache2 > /dev/null 2>&1 && systemctl reload apache2 > /dev/null 2>&1',
      'for pid in $(lsof +L1 2>/dev/null | awk \'$1=="apache2" && /\(deleted\)/ && /var\/log\/apache2/ {print $2}\' | sort -u); do kill "$pid"; done'
    ],
    *             => $profiles::logrotate::default_rule_attributes - ['delaycompress']
  }
}
