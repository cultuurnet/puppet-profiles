describe 'profiles::publiq::versions' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with servername => 'versions.local'" do
        let(:params) { {
          'servername' => 'versions.local'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::publiq::versions').with(
            'servername'      => 'versions.local',
            'serveraliases'   => [],
            'deployment'      => true,
            'service_address' => '127.0.1.1',
            'service_port'    => '6000',
            'puppetdb_url'    => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_class('profiles::ruby') }
          it { is_expected.to contain_class('profiles::apache') }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli('www-data').with(
            'certificate_name' => 'versions.local',
            'server_urls'      => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_file('/var/www/publiq-versions').with(
            'ensure'  => 'directory',
            'owner'   => 'www-data',
            'group'   => 'www-data'
          ) }

          it { is_expected.to contain_file('publiq-versions-env').with(
            'ensure'  => 'file',
            'path'    => '/var/www/publiq-versions/.env',
            'owner'   => 'www-data',
            'group'   => 'www-data',
            'content' => 'PUPPETDB_CONFIG_SOURCE=\'/var/www/.puppetlabs/client-tools/puppetdb.conf\''
          ) }

          it { is_expected.to contain_class('profiles::publiq::versions::deployment') }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
            'destination' => 'http://127.0.1.1:6000/',
            'aliases'     => []
          ) }

          it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Class[profiles::ruby]') }
          it { is_expected.to contain_profiles__puppet__puppetdb__cli('www-data').that_requires('Group[www-data]') }
          it { is_expected.to contain_profiles__puppet__puppetdb__cli('www-data').that_requires('User[www-data]') }
          it { is_expected.to contain_file('/var/www/publiq-versions').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('/var/www/publiq-versions').that_requires('User[www-data]') }
          it { is_expected.to contain_file('publiq-versions-env').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('publiq-versions-env').that_requires('User[www-data]') }
          it { is_expected.to contain_file('publiq-versions-env').that_requires('File[/var/www/publiq-versions]') }

          context "with service_address => 0.0.0.0 and service_port => 5000" do
            let(:params)  { super().merge( {
                'service_address' => '0.0.0.0',
                'service_port'    => 5000
            } ) }

            it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.local').with(
              'destination' => 'http://0.0.0.0:5000/',
              'aliases'     => []
            ) }
          end
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'puppetdb_url'/) }
        end
      end

      context "with servername => versions.publiq.dev, serveraliases => foo.example.com and deployment => false" do
        let(:params) { {
          'servername'    => 'versions.publiq.dev',
          'serveraliases' => 'foo.example.com',
          'deployment'    => false
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to_not contain_class('profiles::publiq::versions::deployment') }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli('www-data').with(
            'certificate_name' => 'versions.publiq.dev',
            'server_urls'      => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://versions.publiq.dev').with(
            'destination' => 'http://127.0.1.1:6000/',
            'aliases'     => 'foo.example.com'
          ) }
        end
      end

      context "with servername => myversions.publiq.dev and serveraliases => [bar.example.com, baz.example.com]" do
        let(:params) { {
          'servername'    => 'myversions.publiq.dev',
          'serveraliases' => ['bar.example.com', 'baz.example.com']
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli('www-data').with(
            'certificate_name' => 'myversions.publiq.dev',
            'server_urls'      => 'http://localhost:8081'
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://myversions.publiq.dev').with(
            'destination' => 'http://127.0.1.1:6000/',
            'aliases'     => ['bar.example.com', 'baz.example.com']
          ) }
        end
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
