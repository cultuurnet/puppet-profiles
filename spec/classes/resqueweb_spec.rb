require 'spec_helper'

describe 'profiles::resqueweb' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_class('resqueweb').that_requires('Apt::Source[cultuurnet-tools]') }
    end
  end
end
