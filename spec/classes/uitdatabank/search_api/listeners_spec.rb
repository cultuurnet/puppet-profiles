describe 'profiles::uitdatabank::search_api::listeners' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('profiles::logrotate') }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::listeners').with(
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-api').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-api',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-cli').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-cli',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-related').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-related',
          'basedir' => '/var/www/udb3-search-service'
        ) }

        it { is_expected.to contain_logrotate__rule('search_api-listeners').with(
          'path'          => '/var/www/udb3-search-service/log/*.log',
          'rotate'        => 10,
          'rotate_every'  => 'day',
          'create'        => true,
          'create_mode'   => '0640',
          'create_owner'  => 'www-data',
          'create_group'  => 'www-data',
          'compress'      => true,
          'delaycompress' => true,
          'sharedscripts' => true,
          'copytruncate'  => false,
          'postrotate'    => '/usr/bin/systemctl restart uitdatabank-consume-*'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-api').that_comes_before('Logrotate::Rule[search_api-listeners]') }
        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-cli').that_comes_before('Logrotate::Rule[search_api-listeners]') }
        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-related').that_comes_before('Logrotate::Rule[search_api-listeners]') }
        it { is_expected.to contain_logrotate__rule('search_api-listeners').that_requires('Group[www-data]') }
        it { is_expected.to contain_logrotate__rule('search_api-listeners').that_requires('User[www-data]') }
      end

      context "with basedir => '/var/www/foo'" do
        let(:params) { {
          'basedir' => '/var/www/foo'
        } }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-api').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-api',
          'basedir' => '/var/www/foo'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-cli').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-cli',
          'basedir' => '/var/www/foo'
        ) }

        it { is_expected.to contain_profiles__uitdatabank__search_api__listener('uitdatabank-consume-related').with(
          'ensure'  => 'present',
          'command' => 'consume-udb3-related',
          'basedir' => '/var/www/foo'
        ) }

        it { is_expected.to contain_logrotate__rule('search_api-listeners').with(
          'path'          => '/var/www/foo/log/*.log',
          'rotate'        => 10,
          'rotate_every'  => 'day',
          'create'        => true,
          'create_mode'   => '0640',
          'create_owner'  => 'www-data',
          'create_group'  => 'www-data',
          'compress'      => true,
          'delaycompress' => true,
          'sharedscripts' => true,
          'copytruncate'  => false,
          'postrotate'    => '/usr/bin/systemctl restart uitdatabank-consume-*'
        ) }
      end
    end
  end
end
