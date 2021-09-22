require 'spec_helper'

describe 'profiles::apt::updates' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}, with all virtual resources realized" do
      let (:facts) { facts }
      let(:pre_condition) { 'Profiles::Apt::Update <| |>' }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }
      it { is_expected.to contain_profiles__apt__update('php') }
      it { is_expected.to contain_profiles__apt__update('rabbitmq') }
      it { is_expected.to contain_profiles__apt__update('nodejs_10.x') }
      it { is_expected.to contain_profiles__apt__update('nodejs_12.x') }
      it { is_expected.to contain_profiles__apt__update('nodejs_14.x') }
      it { is_expected.to contain_profiles__apt__update('elasticsearch') }
      it { is_expected.to contain_profiles__apt__update('yarn') }
      it { is_expected.to contain_profiles__apt__update('aptly') }
    end
  end
end
