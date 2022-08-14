require 'spec_helper'

describe 'profiles::python' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_package('python3.6').with(
          'ensure' => 'installed'
        ) }
      end

      context "with version => 3.7" do
        let(:params) { { 'version' => '3.7' } }

        case facts[:os]['release']['major']
        when '18.04'
          it { is_expected.to contain_apt__ppa('ppa:deadsnakes/ppa') }

          it { is_expected.to contain_package('python3.7').with(
            'ensure' => 'installed'
          ) }

          it { is_expected.to contain_package('python3.7').that_requires('Apt::Ppa[ppa:deadsnakes/ppa]') }
        end
      end
    end
  end
end
