describe 'profiles::platform::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /my/config/file' do
        let(:params) { {
          'config_source' => '/my/config/file'
        } }

        context 'without extra parameters' do
          let(:params) {
            super().merge({})
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::platform::deployment').with(
            'config_source'  => '/my/config/file',
            'version'        => 'latest',
            'repository'     => 'platform-api',
            'puppetdb_url'   => nil
          ) }
        end

        it { is_expected.to contain_apt__source('platform-api') }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_package('platform-api').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('platform-api-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/platform-api/.env',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'source' => '/my/config/file'
        ) }

        it { is_expected.to contain_package('platform-api').that_requires('Apt::Source[platform-api]') }
        it { is_expected.to contain_package('platform-api').that_notifies('Profiles::Deployment::Versions[profiles::platform::deployment]') }
        it { is_expected.to contain_file('platform-api-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('platform-api-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('platform-api-config').that_requires('Package[platform-api]') }
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
