class profiles::uitdatabank::search_api::data_migration (
  Integer $migration_timeout_seconds = 300,
  String  $basedir                   = '/var/www/udb3-search-service'
) inherits ::profiles {

  exec { 'uitdatabank_search_api_data_migration':
      command     => 'bin/app.php elasticsearch:migrate',
      cwd         => $basedir,
      path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
      logoutput   => true,
      timeout     => $migration_timeout_seconds,
      refreshonly => true
    }
}
