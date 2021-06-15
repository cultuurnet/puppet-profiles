require 'spec_helper'

describe 'profiles::deployment::mspotm::backend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source'     => '/foo'
    } }

    include_examples 'operating system support', 'profiles::deployment::mspotm::backend'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-mspotm') }

        it { is_expected.to contain_package('mspotm-backend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('mspotm-backend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::mspotm::backend]') }
        it { is_expected.to contain_package('mspotm-backend').that_requires('Profiles::Apt::Update[publiq-mspotm]') }

        it { is_expected.to contain_file('mspotm-backend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/mspotm-backend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('mspotm-backend-config').that_requires('Package[mspotm-backend]') }

        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').with(
          'command'     => 'composer run-script post-autoload-dump',
          'cwd'         => '/var/www/mspotm-backend',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin'],
          'user'        => 'www-data',
          'environment' => [ 'HOME=/'],
          'logoutput'   => true,
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').that_subscribes_to('Package[mspotm-backend]') }
        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').that_requires('File[mspotm-backend-config]') }

        it { is_expected.to contain_exec('run mspotm database migrations').with(
          'command'     => 'php artisan migrate',
          'cwd'         => '/var/www/mspotm-backend',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin'],
          'user'        => 'www-data',
          'environment' => [ 'HOME=/'],
          'logoutput'   => true,
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('run mspotm database migrations').that_subscribes_to('Package[mspotm-backend]') }
        it { is_expected.to contain_exec('run mspotm database migrations').that_requires('File[mspotm-backend-config]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::mspotm::backend').with(
          'project'      => 'mspotm',
          'packages'     => 'mspotm-backend',
          'puppetdb_url' => nil
        ) }
      end
    end
  end

  context "with config_source => /bar, version => 1.2.3 and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source' => '/bar',
      'version'       => '1.2.3',
      'puppetdb_url'  => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('mspotm-backend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('mspotm-backend').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::mspotm::backend').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end
    end
  end

  context "without parameters" do
    let (:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
