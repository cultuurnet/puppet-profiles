require 'spec_helper'

describe 'profiles::groups' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Group <| |>' }

        it { is_expected.to contain_group('docker').with(
          'ensure' => 'present',
          'gid'    => '300'
        ) }

        it { is_expected.to contain_group('aptly').with(
          'ensure' => 'present',
          'gid'    => '450'
        ) }

        it { is_expected.to contain_group('jenkins').with(
          'ensure' => 'present',
          'gid'    => '451'
        ) }

        it { is_expected.to contain_group('ubuntu').with(
          'ensure' => 'present',
          'gid'    => '1000'
        ) }

        it { is_expected.to contain_group('vagrant').with(
          'ensure' => 'present',
          'gid'    => '1000'
        ) }

        it { is_expected.to contain_group('borgbackup').with(
          'ensure' => 'present',
          'gid'    => '1001'
        ) }

        it { is_expected.to contain_group('www-data').with(
          'ensure' => 'present',
          'gid'    => '33'
        ) }

        it { is_expected.to contain_group('fuseki').with(
          'ensure' => 'present',
          'gid'    => '1002'
        ) }

        it { is_expected.to contain_group('puppet').with(
          'ensure' => 'present',
          'gid'    => '452'
        ) }

        it { is_expected.to contain_group('postgres').with(
          'ensure' => 'present',
          'gid'    => '453'
        ) }

        it { is_expected.to contain_group('puppetdb').with(
          'ensure' => 'present',
          'gid'    => '454'
        ) }

        it { is_expected.to contain_group('redis').with(
          'ensure' => 'present',
          'gid'    => '455'
        ) }

        it { is_expected.to contain_group('mysql').with(
          'ensure' => 'present',
          'gid'    => '456'
        ) }
      end
    end
  end
end
