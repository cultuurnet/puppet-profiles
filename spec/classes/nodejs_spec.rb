require 'spec_helper'

describe 'profiles::nodejs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_apt__source('publiq-nodejs-14') }
        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_class('nodejs').with(
          'manage_package_repo'   => false,
          'nodejs_package_ensure' => '14.16.1-1nodesource1'
        ) }

        it { is_expected.to contain_package('yarn').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[publiq-nodejs-14]') }
        it { is_expected.to contain_package('yarn').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('yarn').that_requires('Class[nodejs]') }
      end

      context "with version => 16.17.0-1nodesource1" do
        let(:params) { { 'version' => '16.17.0-1nodesource1' } }

        it { is_expected.to contain_apt__source('publiq-nodejs-16') }
        it { is_expected.to contain_apt__source('nodejs-16') }

        it { is_expected.to contain_class('nodejs').with(
          'nodejs_package_ensure' => '16.17.0-1nodesource1'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[publiq-nodejs-16]') }
        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[nodejs-16]') }
      end
    end
  end
end
