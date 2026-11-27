describe 'profiles::publiq::mailpit' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with servername => mailpit.local' do
          let(:params) { {
            'servername' => 'mailpit.local'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::publiq::mailpit').with(
            'servername'    => 'mailpit.local',
            'serveraliases' => [],
            'max_messages'  => 500
          ) }

          it { is_expected.to contain_class('profiles::apache') }
          it { is_expected.to contain_class('profiles::mailpit').with(
            'smtp_address' => '0.0.0.0',
            'max_messages' => 500
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mailpit.local').with(
            'aliases'             => [],
            'destination'         => 'http://127.0.0.1:8025/',
            'auth_openid_connect' => true
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mailpit.local').that_requires('Class[profiles::mailpit]') }
        end

        context 'with servername => mailpit.publiq.dev, serveraliases => mymailpit.publiq.dev and max_message => 1000' do
          let(:params) { {
            'servername'    => 'mailpit.publiq.dev',
            'serveraliases' => 'mymailpit.publiq.dev',
            'max_messages'  => 1000
          } }

          it { is_expected.to contain_class('profiles::mailpit').with(
            'smtp_address' => '0.0.0.0',
            'max_messages' => 1000
          ) }

          it { is_expected.to contain_profiles__apache__vhost__reverse_proxy('http://mailpit.publiq.dev').with(
            'aliases'             => 'mymailpit.publiq.dev',
            'destination'         => 'http://127.0.0.1:8025/',
            'auth_openid_connect' => true
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
