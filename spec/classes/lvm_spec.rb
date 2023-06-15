require 'spec_helper'

describe 'profiles::lvm' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_class('lvm').with(
          'manage_pkg' => true
        ) }

        it { is_expected.to contain_file('data').with(
          'ensure' => 'directory',
          'group'  => 'root',
          'mode'   => '0755',
          'owner'  => 'root',
          'path'   => '/data'
        ) }
      end
    end
  end
end
