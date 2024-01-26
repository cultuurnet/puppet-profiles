define profiles::uitdatabank::terms (
  String $directory,
  String $facilities_mapping_source,
  String $themes_mapping_source,
  String $types_mapping_source,
  String $facilities_mapping_filename = 'config.term_mapping_facilities.php',
  String $themes_mapping_filename     = 'config.term_mapping_themes.php',
  String $types_mapping_filename      = 'config.term_mapping_types.php'
) {

  include ::profiles

  realize Group['www-data']
  realize User['www-data']

  $file_default_attributes = {
                               ensure  => 'file',
                               owner   => 'www-data',
                               group   => 'www-data',
                               mode    => '0644',
                               require => [Group['www-data'], User['www-data']]
                             }


  file { "${title} ${facilities_mapping_filename}":
    path   => "${directory}/${facilities_mapping_filename}",
    source => $facilities_mapping_source,
    *      => $file_default_attributes
  }

  file { "${title} ${themes_mapping_filename}":
    path   => "${directory}/${themes_mapping_filename}",
    source => $themes_mapping_source,
    *      => $file_default_attributes
  }

  file { "${title} ${types_mapping_filename}":
    path   => "${directory}/${types_mapping_filename}",
    source => $types_mapping_source,
    *      => $file_default_attributes
  }
}
