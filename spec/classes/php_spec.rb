require 'spec_helper'

RSpec.shared_examples "php" do
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_apt__source('php') }
  it { is_expected.to contain_profiles__apt__update('php') }

  it { is_expected.to contain_class('php::globals').that_requires('Profiles::Apt::Update[php]') }

  it { is_expected.to contain_class('php').that_requires('Profiles::Apt::Update[php]') }
  it { is_expected.to contain_class('php').that_requires('Class[php::globals]') }
end

describe 'profiles::php' do
  include_examples 'operating system support', 'profiles::php'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { { } }

        include_examples 'php'

        it { is_expected.not_to contain_package('composer') }
        it { is_expected.not_to contain_package('git') }
      end

      context 'with with_composer => true' do
        let(:params) { { 'with_composer' => true } }

        include_examples 'php'

        it { is_expected.to contain_package('composer').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
          )
        }
      end
    end
  end
end
