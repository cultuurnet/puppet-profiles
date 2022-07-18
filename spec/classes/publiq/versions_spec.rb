require 'spec_helper'

describe 'profiles::publiq::versions' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::versions').with(
          'deployment'      => true,
          'service_address' => '127.0.0.1',
          'service_port'    => '3000'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('profiles::ruby') }
        it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
          'service_address' => '127.0.0.1',
          'service_port'    => '3000'
        ) }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Group[www-data]') }
        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('User[www-data]') }
        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Class[profiles::ruby]') }
      end

      context "with service_address => 0.0.0.0 and service_port => 5000" do
        let(:params) { {
          'service_address' => '0.0.0.0',
          'service_port'    => 5000
        } }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
          'service_address' => '0.0.0.0',
          'service_port'    => '5000'
        ) }
      end

      context "with deployment => false" do
        let(:params) { {
          'deployment' => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::ruby') }
        it { is_expected.to_not contain_class('profiles::publiq::versions::deployment') }
      end
    end
  end
end
