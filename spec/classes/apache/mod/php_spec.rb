require 'spec_helper'

describe 'profiles::apache::mod::php' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'include profiles::apache' }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_apt__source('php') }
      it { is_expected.to contain_class('apache::mod::php').that_requires('Apt::Source[php]') }
    end
  end
end
