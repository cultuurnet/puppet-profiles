require 'spec_helper'

describe 'profiles::groups' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::groups'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) {
          [ 'include ::profiles', 'Group <| |>' ]
        }

        it { is_expected.to contain_group('borgbackup').with(
          'ensure' => 'present',
          'gid'    => '1001'
          )
        }
      end
    end
  end
end
