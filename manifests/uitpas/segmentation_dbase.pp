class profiles::uitpas::segmentation_dbase (
  String $database_name = 'uitpas_seg_prod_copy',
  String $database_user = '2ndline_ro'
) inherits ::profiles {

  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci'
  }

  profiles::mysql::app_user { "${database_user}@${database_name}":
    password => lookup('data::mysql::2ndline_ro::password', Optional[String], 'first', undef),
    readonly => true,
    remote   => true,
    require  => Mysql_database[$database_name]
  }
}
