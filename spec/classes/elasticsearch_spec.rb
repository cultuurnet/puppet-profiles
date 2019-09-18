require 'spec_helper'

describe 'profiles::elasticsearch' do
  include_examples 'operating system support', 'profiles::elasticsearch'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('elasticsearch') }
        it { is_expected.to contain_profiles__apt__update('elasticsearch') }
      end
    end
  end
end
