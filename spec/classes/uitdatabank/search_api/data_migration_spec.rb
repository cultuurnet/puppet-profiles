describe 'profiles::uitdatabank::search_api::data_migration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::data_migration').with(
          'migration_timeout_seconds' => 300,
          'basedir'                   => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_exec('uitdatabank_search_api_data_migration').with(
          'command'     => 'bin/app.php elasticsearch:migrate',
          'cwd'         => '/var/www/udb3-search-service',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/udb3-search-service'],
          'logoutput'   => true,
          'timeout'     => 300,
          'refreshonly' => true
        ) }
      end

      context "with migration_timeout_seconds => 60 and basedir => /tmp" do
        let(:params) { {
          'migration_timeout_seconds' => 60,
          'basedir'                   => '/tmp'
        } }

        it { is_expected.to contain_exec('uitdatabank_search_api_data_migration').with(
          'command'     => 'bin/app.php elasticsearch:migrate',
          'cwd'         => '/tmp',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/tmp'],
          'logoutput'   => true,
          'timeout'     => 60,
          'refreshonly' => true
        ) }
      end
    end
  end
end
