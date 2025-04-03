describe 'profiles::platform' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => platform.example.com' do
        let(:params) { {
          'servername' => 'platform.example.com'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'without extra parameters' do
            let(:params) {
              super().merge({})
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::platform').with(
              'servername'    => 'platform.example.com',
              'serveraliases' => [],
              'deployment'    => true
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_class('profiles::php') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/platform-api').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::platform::deployment') }

            it { is_expected.to contain_profiles__apache__vhost__php_fpm('http://platform.example.com').with(
              'basedir' => '/var/www/platform-api',
              'public_web_directory' => 'public',
              'aliases'              => [],
              'socket_type'          => 'tcp'
            ) }

            it { is_expected.to contain_file('/var/www/platform-api').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/platform-api').that_requires('User[www-data]') }
            it { is_expected.to contain_class('profiles::platform::deployment').that_subscribes_to('Class[profiles::php]') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_users_source'/) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
