class profiles::uitpas::segmentation_dbase (
  String $database_name = 'uitpas_seg_prod_copy',
  String $ro_user       = '2ndline_ro',
  String $ro_password   = lookup('data::mysql::2ndline_ro::password', Optional[String], 'first', undef),
  String $rw_password   = undef,
  String $rw_user       = undef
) inherits ::profiles {

  mysql_database { $database_name:
    charset => 'utf8mb4',
    collate => 'utf8mb4_unicode_ci'
  }

  profiles::mysql::app_user { "${ro_user}@${database_name}":
    password => $ro_password,
    readonly => true,
    remote   => true,
    require  => Mysql_database[$database_name]
  }

  profiles::mysql::app_user { "${rw_user}@${database_name}":
    password => $rw_password,
    readonly => false,
    remote   => true,
    require  => Mysql_database[$database_name]
  }
}
