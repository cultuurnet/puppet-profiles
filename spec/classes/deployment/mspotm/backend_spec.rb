require 'spec_helper'

describe 'profiles::deployment::mspotm::backend' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      include_examples 'operating system support'

      context "with config_source => /foo" do
        let(:params) { {
          'config_source'     => '/foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('museumpas-mspotm') }

        it { is_expected.to contain_package('mspotm-api').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('mspotm-api').that_notifies('Profiles::Deployment::Versions[profiles::deployment::mspotm::backend]') }
        it { is_expected.to contain_package('mspotm-api').that_requires('Apt::Source[museumpas-mspotm]') }

        it { is_expected.to contain_file('mspotm-backend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/mspotm-api/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('mspotm-backend-config').that_requires('Package[mspotm-api]') }

        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').with(
          'command'     => 'composer run-script post-autoload-dump',
          'cwd'         => '/var/www/mspotm-api',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin'],
          'user'        => 'www-data',
          'environment' => [ 'HOME=/'],
          'logoutput'   => true,
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').that_subscribes_to('Package[mspotm-api]') }
        it { is_expected.to contain_exec('mspotm composer script post-autoload-dump').that_requires('File[mspotm-backend-config]') }

        it { is_expected.to contain_exec('run mspotm database migrations').with(
          'command'     => 'php artisan migrate',
          'cwd'         => '/var/www/mspotm-api',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin'],
          'user'        => 'www-data',
          'environment' => [ 'HOME=/'],
          'logoutput'   => true,
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('run mspotm database migrations').that_subscribes_to('Package[mspotm-api]') }
        it { is_expected.to contain_exec('run mspotm database migrations').that_requires('File[mspotm-backend-config]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::mspotm::backend').with(
          'puppetdb_url' => nil
        ) }
      end

      context "with config_source => /bar, version => 1.2.3 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source' => '/bar',
          'version'       => '1.2.3',
          'puppetdb_url'  => 'http://example.com:8000'
        } }

        it { is_expected.to contain_file('mspotm-backend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('mspotm-api').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::mspotm::backend').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
