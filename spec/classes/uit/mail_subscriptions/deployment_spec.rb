require 'spec_helper'

describe 'profiles::uit::mail_subscriptions::deployment' do

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /foo" do
        let(:params) { {
          'config_source'     => '/foo'
        } }


        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('uit-mail-subscriptions') }

        it { is_expected.to contain_package('uit-mail-subscriptions').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('uit-mail-subscriptions').that_notifies('Profiles::Deployment::Versions[profiles::uit::mail_subscriptions::deployment]') }
        it { is_expected.to contain_package('uit-mail-subscriptions').that_requires('Apt::Source[uit-mail-subscriptions]') }

        it { is_expected.to contain_file('uit-mail-subscriptions-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-mail-subscriptions/packages/rabbitmq/.env',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('uit-mail-subscriptions-config').that_requires('Package[uit-mail-subscriptions]') }

        it { is_expected.not_to contain_file('/etc/default/uit-mail-subscriptions') }

        it { is_expected.to contain_service('uit-mail-subscriptions').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('uit-mail-subscriptions').that_requires('Package[uit-mail-subscriptions]') }
        it { is_expected.to contain_file('uit-mail-subscriptions-config').that_notifies('Service[uit-mail-subscriptions]') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::mail_subscriptions::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::mail_subscriptions::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end

        context "with service_manage => false" do
          let(:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('uit-mail-subscriptions') }
        end
      end

      context "with config_source => /bar, version => 1.2.3, service_defaults_source => /baz, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'config_source'           => '/bar',
          'version'                 => '1.2.3',
          'service_ensure'          => 'stopped',
          'service_defaults_source' => '/baz',
          'service_enable'          => false,
          'puppetdb_url'            => 'http://example.com:8000'
        } }

        it { is_expected.to contain_file('uit-mail-subscriptions-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_file('uit-mail-subscriptions-service-defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/uit-mail-subscriptions',
          'source' => '/baz',
          'owner'  => 'root',
          'group'  => 'root'
        ) }

        it { is_expected.to contain_package('uit-mail-subscriptions').with( 'ensure' => '1.2.3') }

        it { is_expected.to contain_service('uit-mail-subscriptions').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::uit::mail_subscriptions::deployment').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }

        it { is_expected.to contain_file('uit-mail-subscriptions-service-defaults').that_notifies('Service[uit-mail-subscriptions]') }
      end

      context "without parameters" do
        let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
