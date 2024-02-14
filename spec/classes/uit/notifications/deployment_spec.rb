describe 'profiles::uit::notifications::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with config_source => /foo' do
        let(:params) { {
          'config_source'         => '/foo',
          'aws_access_key_id'     => 'secret_key_id',
          'aws_secret_access_key' => 'secret_access_key'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::notifications::deployment').with(
          'config_source'         => '/foo',
          'aws_access_key_id'     => 'secret_key_id',
          'aws_secret_access_key' => 'secret_access_key',
          'version'               => 'latest',
          'repository'            => 'uit-notifications',
          'puppetdb_url'          => nil
        ) }

        it { is_expected.to contain_class('profiles::nodejs') }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }
        it { is_expected.to contain_apt__source('uit-notifications') }

        it { is_expected.to contain_package('uit-notifications').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uit-notifications-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-notifications/packages/notifications/env.yml',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_exec('uit-notifications-deploy').with(
          'command'     => 'yarn notifications deploy',
          'cwd'         => '/var/www/uit-notifications',
          'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-notifications'],
          'environment' => ['AWS_ACCESS_KEY_ID=secret_key_id', 'AWS_SECRET_ACCESS_KEY=secret_access_key'],
          'logoutput'   => true,
          'user'        => 'www-data',
          'refreshonly' => true
        ) }

        it { is_expected.to contain_package('uit-notifications').that_notifies('Profiles::Deployment::Versions[profiles::uit::notifications::deployment]') }
        it { is_expected.to contain_package('uit-notifications').that_notifies('Exec[uit-notifications-deploy]') }
        it { is_expected.to contain_package('uit-notifications').that_requires('Apt::Source[uit-notifications]') }
        it { is_expected.to contain_file('uit-notifications-config').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('uit-notifications-config').that_requires('User[www-data]') }
        it { is_expected.to contain_file('uit-notifications-config').that_requires('Package[uit-notifications]') }
        it { is_expected.to contain_file('uit-notifications-config').that_notifies('Exec[uit-notifications-deploy]') }
        it { is_expected.to contain_exec('uit-notifications-deploy').that_requires('User[www-data]') }
        it { is_expected.to contain_exec('uit-notifications-deploy').that_requires('Class[profiles::nodejs]') }

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::notifications::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::notifications::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end

      context 'with config_source => /bar, aws_access_key_id => foo, aws_secret_access_key => bar, version => 1.2.3, repository => bla and puppetdb_url => http://example.com:8000' do
        let(:params) { {
          'config_source'         => '/bar',
          'aws_access_key_id'     => 'foo',
          'aws_secret_access_key' => 'bar',
          'version'               => '1.2.3',
          'repository'            => 'bla',
          'puppetdb_url'          => 'http://example.com:8000'
        } }

        context "with repository bla defined" do
          let(:pre_condition) { '@apt::source { "bla": location => "http://localhost", release => "focal", repos => "main" }' }

          it { is_expected.to contain_apt__source('bla') }

          it { is_expected.to contain_file('uit-notifications-config').with(
            'source' => '/bar'
          ) }

          it { is_expected.to contain_package('uit-notifications').with( 'ensure' => '1.2.3') }

          it { is_expected.to contain_exec('uit-notifications-deploy').with(
            'command'     => 'yarn notifications deploy',
            'cwd'         => '/var/www/uit-notifications',
            'path'        => ['/usr/local/bin', '/usr/bin', '/bin', '/var/www/uit-notifications'],
            'environment' => ['AWS_ACCESS_KEY_ID=foo', 'AWS_SECRET_ACCESS_KEY=bar'],
            'logoutput'   => true,
            'user'        => 'www-data',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::notifications::deployment').with(
            'puppetdb_url' => 'http://example.com:8000'
          ) }

          it { is_expected.to contain_package('uit-notifications').that_requires('Apt::Source[bla]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'aws_access_key_id'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'aws_secret_access_key'/) }
      end
    end
  end
end
