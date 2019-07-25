class profiles::curator (
  String  $articlelinker_config_source,
  String  $articlelinker_publishers_source,
  String  $api_config_source,
  String  $api_database_name,
  String  $api_database_user,
  String  $api_database_password,
  String  $api_database_host                 = 'localhost',
  String  $articlelinker_env_defaults_source = undef,
  Boolean $update_facts                      = false,
  String  $puppetdb_url                      = ''
) {

  contain ::profiles

  @apt::source { 'publiq-curator':
    location => "http://apt.uitdatabank.be/curator-${environment}",
    release  => 'trusty',
    repos    => 'main',
    key      => {
      'id'     => '2380EA3E50D3776DFC1B03359F4935C80DC9EA95',
      'source' => 'http://apt.uitdatabank.be/gpgkey/cultuurnet.gpg.key'
    },
    include  => {
      'deb' => true,
      'src' => false
    }
  }

  if $articlelinker_env_defaults_source {
    file { '/etc/default/curator-articlelinker':
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      source => $articlelinker_env_defaults_source
    }
  }

  # database, vhost
  mysql::db { $api_database_name:
    user     => $api_database_user,
    password => $api_database_password,
    host     => $api_database_host,
    grant    => ['ALL']
  }

  unless $facts['noop_deploy'] == 'true' {
    class { 'deployment::curator::articlelinker':
      config_source     => $articlelinker_config_source,
      publishers_source => $articlelinker_publishers_source,
      update_facts      => $update_facts,
      puppetdb_url      => $puppetdb_url
    }

    class { 'deployment::curator::api':
      config_source => $api_config_source,
      update_facts  => $update_facts,
      puppetdb_url  => $puppetdb_url
    }

    if $articlelinker_env_defaults_source {
      File['/etc/default/curator-articlelinker'] -> Class['deployment::curator::articlelinker']
    }
  }
}
