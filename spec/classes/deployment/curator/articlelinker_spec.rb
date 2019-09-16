require 'spec_helper'

describe 'profiles::deployment::curator::articlelinker' do
  context "with config_source => /foo and publishers_source => /bar" do
    let (:params) { {
      'config_source'     => '/foo',
      'publishers_source' => '/bar'
    } }

    include_examples 'operating system support', 'profiles::deployment::curator::articlelinker'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-curator') }
        it { is_expected.to contain_profiles__apt__update('publiq-curator') }

        it { is_expected.to contain_package('curator-articlelinker').with( 'ensure' => 'latest') }
        it { is_expected.to contain_package('curator-articlelinker').that_notifies('Profiles::Deployment::Versions[profiles::deployment::curator::articlelinker]') }
        it { is_expected.to contain_package('curator-articlelinker').that_requires('Profiles::Apt::Update[publiq-curator]') }

        it { is_expected.to contain_file('curator-articlelinker-config').with(
          'ensure' => 'file',
          'path'   => '/var/www/curator-articlelinker/config.json',
          'source' => '/foo',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('curator-articlelinker-config').that_requires('Package[curator-articlelinker]') }

        it { is_expected.to contain_file('curator-articlelinker-publishers').with(
          'ensure' => 'file',
          'path'   => '/var/www/curator-articlelinker/publishers.json',
          'source' => '/bar',
          'owner'  => 'www-data',
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('curator-articlelinker-publishers').that_requires('Package[curator-articlelinker]') }

        it { is_expected.not_to contain_file('/etc/defaults/curator-articlelinker') }

        it { is_expected.to contain_service('curator-articlelinker').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_service('curator-articlelinker').that_requires('Package[curator-articlelinker]') }

        it { is_expected.to contain_file('curator-articlelinker-config').that_notifies('Service[curator-articlelinker]') }
        it { is_expected.to contain_file('curator-articlelinker-publishers').that_notifies('Service[curator-articlelinker]') }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::curator::articlelinker').with(
          'project'      => 'curator',
          'packages'     => 'curator-articlelinker',
          'puppetdb_url' => nil
        ) }

        context "with service_manage => false" do
          let (:params) {
            super().merge({
              'service_manage' => false
            } )
          }

          it { is_expected.not_to contain_service('curator-articlelinker') }
        end
      end
    end
  end

  context "with config_source => /bar, publishers_source => /baz, env_defaults_source => /tmp/a, service_ensure => stopped, service_enable = false and puppetdb_url => http://example.com:8000" do
    let (:params) { {
      'config_source'       => '/bar',
      'publishers_source'   => '/baz',
      'env_defaults_source' => '/tmp/a',
      'service_ensure'      => 'stopped',
      'service_enable'      => false,
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to contain_file('curator-articlelinker-config').with(
          'source' => '/bar',
        ) }

        it { is_expected.to contain_file('curator-articlelinker-publishers').with(
          'source' => '/baz',
        ) }

        it { is_expected.to contain_service('curator-articlelinker').with(
          'ensure'    => 'stopped',
          'enable'    => false
        ) }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::curator::articlelinker').with(
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
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'publishers_source'/) }
      end
    end
  end
end
