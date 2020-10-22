class profiles::deployment::uit::content (
  String           $config_source,
  String           $package_version         = 'latest',
  Optional[String] $puppetdb_url            = undef
) {

  $basedir = '/var/www/uit-content'

  contain ::profiles

  include ::profiles::repositories
  include ::profiles::deployment::uit

  realize Apt::Source['cultuurnet-tools']
  realize Profiles::Apt::Update['cultuurnet-tools']

  realize Apt::Source['publiq-uit']
  realize Profiles::Apt::Update['publiq-uit']
}
