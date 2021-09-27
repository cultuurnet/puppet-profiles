require 'spec_helper'

describe 'profiles::nodejs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_profiles__apt__update('nodejs_10.x') }

        it { is_expected.to contain_class('nodejs').with(
          'manage_package_repo'   => false,
          'nodejs_package_ensure' => '10.14.0-1nodesource1'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Profiles::Apt::Update[nodejs_10.x]') }
      end

      context "with version => 12.18.3-1nodesource1" do
        let(:params) { { 'version' => '12.18.3-1nodesource1' } }

        it { is_expected.to contain_profiles__apt__update('nodejs_12.x') }

        it { is_expected.to contain_class('nodejs').with(
          'nodejs_package_ensure' => '12.18.3-1nodesource1'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Profiles::Apt::Update[nodejs_12.x]') }
      end
    end
  end
end
