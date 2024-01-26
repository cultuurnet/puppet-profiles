describe 'profiles::uit::api' do
  context "with servername => foo.example.com" do
    let(:params) { {
      'servername' => 'foo.example.com'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without extra parameters" do
          let(:params) {
            super().merge({})
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uit::api').with(
              'servername'    => 'foo.example.com',
              'serveraliases' => [],
              'deployment'    => true,
              'service_port'  => 4000
            ) }

            it { is_expected.to contain_group('www-data') }
            it { is_expected.to contain_user('www-data') }

            it { is_expected.to contain_class('profiles::nodejs') }
            it { is_expected.to contain_class('profiles::redis') }
            it { is_expected.to contain_class('profiles::mysql::server') }
            it { is_expected.to contain_class('profiles::apache') }

            it { is_expected.to contain_file('/var/www/uit-api').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_file('uit-api-log').with(
              'ensure' => 'directory',
              'owner'  => 'www-data',
              'group'  => 'www-data'
            ) }

            it { is_expected.to contain_class('profiles::uit::api::deployment').with(
              'service_port' => 4000
            ) }

            it { is_expected.to contain_file('/var/www/uit-api').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('/var/www/uit-api').that_requires('User[www-data]') }
            it { is_expected.to contain_file('uit-api-log').that_requires('Group[www-data]') }
            it { is_expected.to contain_file('uit-api-log').that_requires('User[www-data]') }
            it { is_expected.to contain_file('uit-api-log').that_requires('File[/var/www/uit-api]') }
            it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::nodejs]') }
            it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::mysql::server]') }
            it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('Class[profiles::redis]') }
            it { is_expected.to contain_class('profiles::uit::api::deployment').that_requires('File[uit-api-log]') }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
          end
        end

        context "with " do
          let(:params) {
            super().merge( {
            } )
          }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to compile.with_all_deps }

          end
        end

        context "with deployment => false" do
          let(:params) {
            super().merge( {
              'deployment' => false
            } )
          }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to_not contain_class('profiles::uit::api::deployment') }
        end
      end
    end
  end

  context "with servername => bar.example.com" do
    let(:params) { {
      'servername' => 'bar.example.com'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').with(
            'destination' => 'http://127.0.0.1:4000/',
            'aliases'     => []
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::uit::api::deployment]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('Class[profiles::apache]') }
          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://bar.example.com').that_requires('File[/var/www/uit-api]') }
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
