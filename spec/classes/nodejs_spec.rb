require 'spec_helper'

describe 'profiles::nodejs' do
  include_examples 'operating system support', 'profiles::nodejs'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to contain_apt__source('nodejs_10.x') }
        it { is_expected.to contain_profiles__apt__update('nodejs_10.x') }

        it { is_expected.to contain_class('nodejs').that_requires('Profiles::Apt::Update[nodejs_10.x]') }
      end

      context "with major_version => 12" do
        let(:params) { { 'major_version' => 12 } }

        it { is_expected.to contain_apt__source('nodejs_12.x') }
        it { is_expected.to contain_profiles__apt__update('nodejs_12.x') }

        it { is_expected.to contain_class('nodejs').that_requires('Profiles::Apt::Update[nodejs_12.x]') }
      end
    end
  end
end
