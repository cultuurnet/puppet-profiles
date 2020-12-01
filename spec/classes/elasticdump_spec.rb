require 'spec_helper'

describe 'profiles::elasticdump' do
  include_examples 'operating system support', 'profiles::elasticdump'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::nodejs') }

        it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }
        it { is_expected.to contain_package('elasticdump') }

        it { is_expected.to contain_package('elasticdump').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }
        it { is_expected.to contain_package('elasticdump').that_requires('Class[profiles::nodejs]') }
      end
    end
  end
end
