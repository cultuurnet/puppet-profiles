class profiles::uitdatabank::search::data_migration (
  Integer $migration_timeout_seconds = 300
) inherits ::profiles {

  $basedir = '/var/www/udb3-search-service'

  exec { 'uitdatabank_search_data_migration':
      command     => 'bin/app.php elasticsearch:migrate',
      cwd         => $basedir,
      path        => [ '/usr/local/bin', '/usr/bin', '/bin', $basedir],
      logoutput   => true,
      timeout     => $migration_timeout_seconds,
      refreshonly => true
    }
}
