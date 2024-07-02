describe 'profiles::museumpas::automatic_renewal_mail' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'api_url => https://museumpas.example.com and jwt_token => abc' do
        let(:params) { {
          'api_url'   => 'https://museumpas.example.com',
          'jwt_token' => 'abc'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::museumpas::automatic_renewal_mail').with(
          'ensure'    => 'present',
          'api_url'   => 'https://museumpas.example.com',
          'jwt_token' => 'abc',
          'hour'      => '0',
          'minute'    => '0'
        ) }

        it { is_expected.to contain_cron('profiles::museumpas::automatic_renewal_mail').with(
          'ensure'      => 'present',
          'environment' => [ 'MAILTO=infra+cron@publiq.be'],
          'command'     => "/usr/bin/curl -X 'POST' -H 'Authorization: Bearer abc' https://museumpas.example.com/rest/system/autorenewalReminder",
          'hour'        => 0,
          'minute'      => 0
        ) }
      end

      context 'api_url => https://foo.example.com, jwt_token => def, hour => 3 and minute => 14' do
        let(:params) { {
          'api_url'   => 'https://foo.example.com',
          'jwt_token' => 'def',
          'hour'      => 3,
          'minute'    => 14
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::museumpas::automatic_renewal_mail').with(
          'ensure'    => 'present',
          'api_url'   => 'https://foo.example.com',
          'jwt_token' => 'def',
          'hour'      => 3,
          'minute'    => 14
        ) }

        it { is_expected.to contain_cron('profiles::museumpas::automatic_renewal_mail').with(
          'ensure'      => 'present',
          'environment' => [ 'MAILTO=infra+cron@publiq.be'],
          'command'     => "/usr/bin/curl -X 'POST' -H 'Authorization: Bearer def' https://foo.example.com/rest/system/autorenewalReminder",
          'hour'        => 3,
          'minute'      => 14
        ) }
      end

      context 'with ensure => absent' do
        let(:params) { {
          'ensure' => 'absent'
        } }

        it { is_expected.to contain_cron('profiles::museumpas::automatic_renewal_mail').with(
          'ensure' => 'absent'
        ) }
      end

      context 'without api_url' do
        let(:params) { {
          'jwt_token' => 'xyz'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_url'/) }
      end

      context 'without jwt_token' do
        let(:params) { {
          'api_url' => 'https://foo.example.com'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'jwt_token'/) }
      end
    end
  end
end
