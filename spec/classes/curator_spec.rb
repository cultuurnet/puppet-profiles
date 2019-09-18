require 'spec_helper'

describe 'profiles::curator' do
  let (:pre_condition) { 'include ::profiles' }

  context "with articlelinker_config_source => /foo, articlelinker_publishers_source => /bar, articlelinker_env_defaults_source => /defaults, api_config_source => /baz and api_hostname => example.com" do
    let (:params) { {
      'articlelinker_config_source'       => '/foo',
      'articlelinker_publishers_source'   => '/bar',
      'articlelinker_env_defaults_source' => '/defaults',
      'api_config_source'                 => '/baz',
      'api_hostname'                      => 'example.com'
    } }

    include_examples 'operating system support', 'profiles::curator'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        context "with the noop_deploy fact set to true" do
          let (:facts) do
            super().merge({ 'noop_deploy' => 'true' })
          end

          it { is_expected.not_to contain_class('profiles::deployment::curator::api') }
          it { is_expected.not_to contain_class('profiles::deployment::curator::articlelinker') }
        end

        context "with api_local_database => true, api_local_database_name => one, api_local_database_user => two and api_local_database_password => three" do
          let (:params) {
            super().merge({
              'api_local_database'          => true,
              'api_local_database_name'     => 'one',
              'api_local_database_user'     => 'two',
              'api_local_database_password' => 'three'
            } )
          }

          it { is_expected.to contain_file('/var/www/curator-api').with(
            'ensure' => 'directory'
          ) }

          it { is_expected.to contain_file('/var/www/curator-api').that_comes_before('Class[profiles::deployment::curator::api]') }

          it { is_expected.to contain_mysql__db('one').with(
            'user'     => 'two',
            'password' => 'three',
            'host'     => 'localhost',
            'grant'    => ['ALL']
          ) }

          it { is_expected.to contain_class('profiles::deployment::curator::api').with(
            'config_source' => '/baz',
            'puppetdb_url'  => nil
          ) }

          it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
            'config_source'       => '/foo',
            'publishers_source'   => '/bar',
            'env_defaults_source' => '/defaults',
            'service_manage'      => true,
            'service_ensure'      => 'running',
            'service_enable'      => true,
            'puppetdb_url'        => nil
          ) }

          context "with articlelinker_service_manage => false, articlelinker_service_ensure => stopped and articlelinker_service_enable => false" do
            let (:params) {
              super().merge({
                'articlelinker_service_manage' => false,
                'articlelinker_service_ensure' => 'stopped',
                'articlelinker_service_enable' => false
              } )
            }

            it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
              'config_source'       => '/foo',
              'publishers_source'   => '/bar',
              'env_defaults_source' => '/defaults',
              'service_manage'      => false,
              'service_ensure'      => 'stopped',
              'service_enable'      => false,
              'puppetdb_url'        => nil
            ) }
          end

          context "with puppetdb_url => http://localhost:8080" do
            let (:params) {
              super().merge({
                'puppetdb_url'          => 'http://localhost:8080'
              } )
            }

            it { is_expected.to contain_class('profiles::deployment::curator::api').with(
              'puppetdb_url'  => 'http://localhost:8080'
            ) }

            it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
              'puppetdb_url'  => 'http://localhost:8080'
            ) }
          end
        end
      end
    end
  end

  context "without parameters" do
    let (:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_publishers_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_hostname'/) }
      end
    end
  end
end
