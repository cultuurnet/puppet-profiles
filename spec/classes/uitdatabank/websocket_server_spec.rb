require 'spec_helper'

describe 'profiles::uitdatabank::websocket_server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with hieradata" do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::websocket_server').with(
            'deployment'  => true,
            'listen_port' => 3000
          ) }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment') }

          it { is_expected.to contain_class('profiles::uitdatabank::websocket_server::deployment').that_requires('Class[profiles::nodejs]') }
        end

        context "with deployment => false" do
          let(:params) { {
            'deployment' => false
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to_not contain_class('profiles::uitdatabank::websocket_server::deployment') }
        end
      end

      context "without hieradata" do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
