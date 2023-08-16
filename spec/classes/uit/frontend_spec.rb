require 'spec_helper'

describe 'profiles::uit::frontend' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uit::frontend').with(
            'deployment' => true
          ) }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to contain_class('profiles::uit::frontend::deployment') }

          it { is_expected.to contain_class('profiles::uit::frontend::deployment').that_requires('Class[profiles::nodejs]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context "with deployment => false" do
        let(:params) { {
          'deployment' => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::nodejs') }
        it { is_expected.to_not contain_class('profiles::uit::frontend::deployment') }
      end
    end
  end
end
