class profiles::uitdatabank::search_api::data_integration (
  String           $bucket_dumplocation = '',
  Boolean          $dump_schedule       = true,
  Integer          $dump_hour           = 0,
  String           $timezone            = 'UTC'

) inherits profiles {

  include profiles::data_integration

  file { 'elasticdump_to_gcs':
    ensure  => 'file',
    path    => '/usr/local/bin/elasticdump_to_gcs',
    content => template('profiles/uitdatabank/search_api/elasticdump_to_gcs.erb'),
    mode    => '0755',
    require => Class['Profiles::Data_integration'],
    before  => Cron['elasticdump_to_gcs']
  }

  cron { 'elasticdump_to_gcs':
    ensure      => $dump_schedule ? {
                     true  => 'present',
                     false => 'absent'
                   },
    environment => ['SHELL=/bin/bash', "TZ=${timezone}", 'MAILTO=infra+cron@publiq.be'],
    command     => "/usr/bin/test $(date +\\%0H) -eq ${dump_hour} && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/\$(curl -s -XGET 'http://localhost:9200/_cat/aliases/udb3_core_read?h=idx').json",
    hour        => '*',
    minute      => '00'
  }
}
