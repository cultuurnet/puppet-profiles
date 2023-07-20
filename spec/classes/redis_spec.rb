require 'spec_helper'

describe 'profiles::redis' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::redis').with(
          'version'          => 'installed',
          'lvm'              => false,
          'volume_group'     => nil,
          'volume_size'      => nil
        ) }

        it { is_expected.to contain_group('redis') }
        it { is_expected.to contain_user('redis') }

        it { is_expected.to contain_class('redis').with(
          'workdir'      => '/var/lib/redis',
          'workdir_mode' => '0755'
        )}

        it { is_expected.to contain_group('redis').that_comes_before('Class[redis]') }
        it { is_expected.to contain_user('redis').that_comes_before('Class[redis]') }
      end

#       context "with volume_group datavg present" do
#         let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }
#
#         context "with version => 1.2.3, lvm => true, volume_group => datavg and volume_size => 20G" do
#           let(:params) { {
#             'version'          => '1.2.3',
#             'lvm'              => true,
#             'volume_group'     => 'datavg',
#             'volume_size'      => '20G'
#           } }
#
#           it { is_expected.to contain_class('redis').with(
#             'ensure' => '1.2.3'
#           ) }
#
#           it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
#             'volume_group' => 'datavg',
#             'size'         => '20G',
#             'fs_type'      => 'ext4',
#             'mountpoint'   => '/data/redis',
#             'owner'        => 'redis',
#             'group'        => 'redis'
#           ) }
#
#           it { is_expected.to contain_file('/var/lib/redis').with(
#             'ensure' => 'link',
#             'target' => '/data/redis',
#             'force'  => true,
#             'owner'  => 'redis',
#             'group'  => 'redis'
#           ) }
#
#           it { is_expected.to contain_group('redis').that_comes_before('Profiles::Lvm::Mount[redisdata]') }
#           it { is_expected.to contain_user('redis').that_comes_before('Profiles::Lvm::Mount[redisdata]') }
#           it { is_expected.to contain_profiles__lvm__mount('redisata').that_comes_before('Class[redis]') }
#           it { is_expected.to contain_file('/var/lib/redis').that_requires('Profiles::Lvm::Mount[redisdata]') }
#           it { is_expected.to contain_file('/var/lib/redis').that_comes_before('Class[redis]') }
#         end
#       end
#
#       context "with volume_group myvg present" do
#         let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }
#
#         context "with lvm => true, volume_group => myvg and volume_size => 10G" do
#           let(:params) { {
#             'lvm'          => true,
#             'volume_group' => 'myvg',
#             'volume_size'  => '10G'
#           } }
#
#           it { is_expected.to contain_profiles__lvm__mount('redisdata').with(
#             'volume_group' => 'myvg',
#             'size'         => '10G',
#             'mountpoint'   => '/data/redis',
#             'owner'        => 'redis',
#             'group'        => 'redis'
#           ) }
#         end
#       end
#
#       context "with lvm => true, volume_group => datavg" do
#         let(:params) { {
#           'lvm'          => true,
#           'volume_group' => 'myvg'
#         } }
#
#         it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
#       end
#
#       context "with lvm => true, volume_size => 100G" do
#         let(:params) { {
#           'lvm'         => true,
#           'volume_size' => '100G'
#         } }
#
#         it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
#       end
     end
   end
 end
