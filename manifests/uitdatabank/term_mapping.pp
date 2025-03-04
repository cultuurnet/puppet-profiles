define profiles::uitdatabank::term_mapping (
  String $basedir,
  String $facilities_source,
  String $themes_source,
  String $types_source,
  String $facilities_mapping_filename = 'facet_mapping_facilities.yml',
  String $themes_mapping_filename     = 'facet_mapping_themes.yml',
  String $types_mapping_filename      = 'facet_mapping_types.yml'
) {

  include ::profiles

  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'www-data',
                               group   => 'www-data',
                               mode    => '0644',
                               require => [Group['www-data'], User['www-data']]
                             }

  realize Group['www-data']
  realize User['www-data']

  file { "${title} facilities":
    path   => "${basedir}/${facilities_mapping_filename}",
    source => $facilities_source,
    *      => $file_default_attributes
  }

  file { "${title} themes":
    path   => "${basedir}/${themes_mapping_filename}",
    source => $themes_source,
    *      => $file_default_attributes
  }

  file { "${title} types":
    path   => "${basedir}/${types_mapping_filename}",
    source => $types_source,
    *      => $file_default_attributes
  }
}
