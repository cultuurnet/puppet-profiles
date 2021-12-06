require 'spec_helper'

describe 'profiles::ruby' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::ruby').with(
          'with_dev'     => false
        ) }

        it { is_expected.to contain_package('ruby') }
        it { is_expected.not_to contain_package('bundler') }
        it { is_expected.not_to contain_package('git') }
        it { is_expected.not_to contain_package('ri') }
        it { is_expected.not_to contain_package('ruby-dev') }
        it { is_expected.not_to contain_package('libffi-dev') }
      end

      context 'with_dev => true' do
        let(:params) { {
          'with_dev'     => true
        } }

        it { is_expected.to contain_package('bundler').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('ri').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('ruby-dev').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('libffi-dev').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('bundler').that_requires('Package[ruby]') }
      end
    end
  end
end
