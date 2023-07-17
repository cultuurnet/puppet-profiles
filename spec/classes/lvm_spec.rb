require 'spec_helper'

describe 'profiles::lvm' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::lvm').with(
          'volume_groups' => {}
        ) }

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

        it { is_expected.to have_physical_volume_resource_count(0) }
        it { is_expected.to have_volume_group_resource_count(0) }
      end

      context "with volume_groups => { datavg => { physical_volumes => '/dev/xvdb' } }" do
        let(:params) { {
          'volume_groups' => { 'datavg' => { 'physical_volumes' => '/dev/xvdb' }}
        } }

        it { is_expected.to contain_physical_volume('/dev/xvdb').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('datavg').with(
          'ensure'           => 'present',
          'physical_volumes' => '/dev/xvdb'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Volume_group[datavg]') }
      end

      context "with volume_groups => { data1vg => { physical_volumes => '/dev/xvdb' }, data2vg => { physical_volumes => [ '/dev/xvdc', '/dev/xvdd'] }}" do
        let(:params) { {
          'volume_groups' => {
                               'data1vg' => { 'physical_volumes' => '/dev/xvdb' },
                               'data2vg' => { 'physical_volumes' => ['/dev/xvdc', '/dev/xvdd'] }
                             }
        } }

        it { is_expected.to contain_physical_volume('/dev/xvdb').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdc').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdd').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('data1vg').with(
          'ensure'           => 'present',
          'physical_volumes' => '/dev/xvdb'
        ) }

        it { is_expected.to contain_volume_group('data2vg').with(
          'ensure'           => 'present',
          'physical_volumes' => ['/dev/xvdc', '/dev/xvdd']
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Volume_group[data1vg]') }
        it { is_expected.to contain_physical_volume('/dev/xvdc').that_comes_before('Volume_group[data2vg]') }
        it { is_expected.to contain_physical_volume('/dev/xvdd').that_comes_before('Volume_group[data2vg]') }
      end
    end
  end
end
