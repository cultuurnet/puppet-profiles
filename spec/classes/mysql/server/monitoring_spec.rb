describe 'profiles::mysql::server::monitoring' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node bar.example.com' do
        let(:node) { 'bar.example.com' }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__app_user('newrelic@*').with(
            'password' => 'tc6LuLOVkB4yUAJautU4',
            'remote'   => true,
            'readonly' => true
          ) }

          it { is_expected.to contain_profiles__newrelic__infrastructure__integration('mysql').with(
            'configuration' => {
                                 'HOSTNAME'          => 'bar.example.com',
                                 'PORT'              => 3306,
                                 'USERNAME'          => 'newrelic',
                                 'PASSWORD'          => 'tc6LuLOVkB4yUAJautU4',
                                 'METRICS'           => true,
                                 'INVENTORY'         => true,
                                 'REMOTE_MONITORING' => true
                               }

          ) }

          it { is_expected.to contain_profiles__newrelic__infrastructure__logging('mysql-error-log').with(
            'source' => '/var/log/mysql/error.log'
          ) }

          it { is_expected.to contain_profiles__newrelic__infrastructure__logging('mysql-slow-query-log').with(
            'source' => '/var/log/mysql/slow-query.log'
          ) }

          it { is_expected.to contain_profiles__newrelic__infrastructure__integration('mysql').that_requires('Profiles::Mysql::App_user[newrelic@*]') }
        end
      end
    end
  end
end
