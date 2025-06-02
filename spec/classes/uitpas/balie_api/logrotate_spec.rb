describe 'profiles::uitpas::balie_api::logrotate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::balie_api::logrotate').with(
          'basedir' => '/var/www/uitpas-balie-api'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('profiles::logrotate') }

        it { is_expected.to contain_logrotate__rule('uitpas-balie-api').with(
          'path'          => '/var/www/uitpas-balie-api/log/*.log',
          'rotate'        => 10,
          'create_owner'  => 'www-data',
          'create_group'  => 'www-data',
          'postrotate'    => 'systemctl restart uitpas-balie-api',
          'rotate_every'  => 'day',
          'missingok'     => true,
          'create'        => true,
          'ifempty'       => true,
          'create_mode'   => '0640',
          'compress'      => true,
          'delaycompress' => true,
          'sharedscripts' => true
        ) }

        it { is_expected.to contain_logrotate__rule('uitpas-balie-api').that_requires('Group[www-data]') }
        it { is_expected.to contain_logrotate__rule('uitpas-balie-api').that_requires('User[www-data]') }
      end

      context 'with basedir => /tmp/foo' do
        let(:params) { {
          'basedir' => '/tmp/foo'
        } }

        it { is_expected.to contain_logrotate__rule('uitpas-balie-api').with(
          'path' => '/tmp/foo/log/*.log',
        ) }
      end
    end
  end
end
