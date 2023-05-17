require 'spec_helper'

describe 'profiles::users' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'User <| |>' }

        it { is_expected.to contain_user('aptly').with(
          'ensure'         => 'present',
          'gid'            => 'aptly',
          'home'           => '/home/aptly',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '450'
        ) }

        it { is_expected.to contain_user('jenkins').with(
          'ensure'         => 'present',
          'gid'            => 'jenkins',
          'home'           => '/var/lib/jenkins',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '451'
        ) }

        it { is_expected.to contain_user('ubuntu').with(
          'ensure'         => 'present',
          'gid'            => 'ubuntu',
          'home'           => '/home/ubuntu',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
        ) }

        it { is_expected.to contain_user('vagrant').with(
          'ensure'         => 'present',
          'gid'            => 'vagrant',
          'home'           => '/home/vagrant',
          'managehome'     => true,
          'purge_ssh_keys' => false,
          'shell'          => '/bin/bash',
          'uid'            => '1000'
        ) }

        it { is_expected.to contain_user('borgbackup').with(
          'ensure'         => 'present',
          'gid'            => 'borgbackup',
          'home'           => '/home/borgbackup',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1001'
        ) }

        it { is_expected.to contain_user('www-data').with(
          'ensure'         => 'present',
          'gid'            => 'www-data',
          'home'           => '/var/www',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/usr/sbin/nologin',
          'uid'            => '33'
        ) }

        it { is_expected.to contain_user('fuseki').with(
          'ensure'         => 'present',
          'gid'            => 'fuseki',
          'home'           => '/home/fuseki',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => '1002'
        ) }

        it { is_expected.to contain_user('puppet').with(
          'ensure'         => 'present',
          'gid'            => 'puppet',
          'home'           => '/opt/puppetlabs/server/data/puppetserver',
          'managehome'     => false,
          'purge_ssh_keys' => true,
          'shell'          => '/usr/sbin/nologin',
          'uid'            => '452'
        ) }
      end
    end
  end
end
