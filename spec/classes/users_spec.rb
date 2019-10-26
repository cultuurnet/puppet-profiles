require 'spec_helper'

describe 'profiles::users' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support', 'profiles::users'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'User <| |>' }

        it { is_expected.to contain_user('ubuntu').with(
          'ensure'         => 'present',
          'gid'            => 'ubuntu',
          'home'           => '/home/ubuntu',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
          )
        }

        it { is_expected.to contain_user('vagrant').with(
          'ensure'         => 'present',
          'gid'            => 'vagrant',
          'home'           => '/home/vagrant',
          'managehome'     => true,
          'purge_ssh_keys' => false,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
          )
        }

        it { is_expected.to contain_user('borgbackup').with(
          'ensure'         => 'present',
          'gid'            => 'borgbackup',
          'home'           => '/home/borgbackup',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1001'
          )
        }
      end
    end
  end
end
