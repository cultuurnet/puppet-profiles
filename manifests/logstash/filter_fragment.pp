define profiles::logstash::filter_fragment (
  String $log_type,
  String $filter
) {

  concat::fragment { $title:
    target  => '/etc/logstash/conf.d/filter.conf',
    content => template('profiles/logstash/filter_fragment.erb'),
    tag     => 'logstash_filter'
  }
}
