require 'spec_helper'

describe 'profiles::terraform' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::terraform').with(
          'version'          => 'latest'
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('terraform').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_package('terrafile').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[terrafile]') }
      end

      context "with version => 1.2.3" do
        let(:params) { {
          'version'           => '1.2.3',
          'terrafile_version' => '4.5.6'
        } }

        it { is_expected.to contain_package('terraform').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_package('terrafile').with(
          'ensure' => '4.5.6'
        ) }
      end
    end
  end
end
