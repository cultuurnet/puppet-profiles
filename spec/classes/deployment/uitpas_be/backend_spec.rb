require 'spec_helper'

describe 'profiles::deployment::uitpas_be::backend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-uitpasbe') }

        it { is_expected.to contain_package('uitpasbe-backend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitpasbe-backend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uitpas_be::backend]') }
        it { is_expected.to contain_package('uitpasbe-backend').that_requires('Profiles::Apt::Update[publiq-uitpasbe]') }

        it { is_expected.to contain_file('uitpasbe-backend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpasbe-backend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpasbe-backend-config').that_requires('Package[uitpasbe-backend]') }

        it { is_expected.to contain_exec('uitpasbe-backend_cache_clear').with(
          'command'     => 'php bin/console cache:clear',
          'cwd'         => '/var/www/uitpasbe-backend',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/uitpasbe-backend'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uitpasbe-backend_cache_clear').that_subscribes_to('Package[uitpasbe-backend]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitpas_be::backend').with(
          'project'      => 'uitpasbe',
          'packages'     => 'uitpasbe-backend',
          'puppetdb_url' => nil
        ) }
      end
    end
  end

  context "with config_source => /bar, version => 9.8.7 and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source' => '/bar',
      'version'       => '9.8.7',
      'puppetdb_url'  => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uitpasbe-backend-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_package('uitpasbe-backend').with( 'ensure' => '9.8.7') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitpas_be::backend').with(
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
