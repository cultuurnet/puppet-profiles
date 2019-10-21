require 'spec_helper'

describe 'profiles::deployment::uitpas_be::backend' do
  context "with config_source => /foo" do
    let (:params) { {
      'config_source' => '/foo'
    } }

    include_examples 'operating system support', 'profiles::deployment::uitpas_be::backend'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-uitpas.be') }
        it { is_expected.to contain_profiles__apt__update('publiq-uitpas.be') }

        it { is_expected.to contain_package('uitpas.be-backend').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uitpas.be-backend').that_notifies('Profiles::Deployment::Versions[profiles::deployment::uitpas_be::backend]') }
        it { is_expected.to contain_package('uitpas.be-backend').that_requires('Profiles::Apt::Update[publiq-uitpas.be]') }

        it { is_expected.to contain_file('uitpas.be-backend-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uitpas.be-backend/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uitpas.be-backend-config').that_requires('Package[uitpas.be-backend]') }

        it { is_expected.to contain_exec('uitpas.be-backend_cache_clear').with(
          'command'     => 'php bin/console cache:clear',
          'cwd'         => '/var/www/uitpas.be-backend',
          'user'        => 'www-data',
          'group'       => 'www-data',
          'path'        => [ '/usr/local/bin', '/usr/bin', '/bin', '/var/www/uitpas.be-backend'],
          'refreshonly' => true
        ) }

        it { is_expected.to contain_exec('uitpas.be-backend_cache_clear').that_subscribes_to('Package[uitpas.be-backend]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uitpas_be::backend').with(
          'project'      => 'uitpas.be',
          'packages'     => 'uitpas.be-backend',
          'puppetdb_url' => nil
        ) }
      end
    end
  end

  context "with config_source => /bar and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source' => '/bar',
      'puppetdb_url'  => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('uitpas.be-backend-config').with(
          'source' => '/bar',
        ) }

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
