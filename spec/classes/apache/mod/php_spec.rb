require 'spec_helper'

describe 'profiles::apache::mod::php' do
  let (:pre_condition) { 'include ::profiles; class { apache: mpm_module => "prefork" }' }

  include_examples 'operating system support', 'profiles::apache::mod::php'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__apt__update('php') }

      it { is_expected.to contain_class('apache::mod::php').that_requires('Profiles::Apt::Update[php]') }
    end
  end
end
