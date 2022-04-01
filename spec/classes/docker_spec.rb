require 'spec_helper'

describe 'profiles::docker' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with virtual user resources declared" do
        let(:pre_condition) { [
          '@user { "myuser": }',
          '@user { "alice": }',
          '@user { "bob": }'
        ] }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('docker') }

          it { is_expected.to contain_group('docker') }

          it { is_expected.to contain_class('profiles::docker').with(
            'users' => []
          ) }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_group('docker').that_comes_before('Class[docker]') }
          it { is_expected.to contain_apt__source('docker').that_comes_before('Class[docker]') }
        end

        context "with users => myuser" do
          let(:params) { {
            'users' => 'myuser'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('docker') }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_user('myuser') }
          it { is_expected.to contain_group('docker') }

          it { is_expected.to contain_exec('Add user myuser to docker group').with(
            'command' => 'usermod -aG docker myuser',
            'path'    => [ '/usr/sbin', '/usr/bin', '/bin'],
            'unless'  => 'getent group docker | cut -d \':\' -f 4 | tr \',\' \'\n\' | grep -q \'^myuser$\''
          ) }

          it { is_expected.to contain_user('myuser').that_comes_before('Exec[Add user myuser to docker group]') }
          it { is_expected.to contain_group('docker').that_comes_before('Exec[Add user myuser to docker group]') }

          it { is_expected.to contain_user('myuser').that_comes_before('Class[docker]') }
          it { is_expected.to contain_group('docker').that_comes_before('Class[docker]') }
        end

        context "with users => [ 'alice', 'bob']" do
          let(:params) { {
            'users' => [ 'alice', 'bob']
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_user('alice') }
          it { is_expected.to contain_user('bob') }

          it { is_expected.to contain_exec('Add user alice to docker group').with(
            'command' => 'usermod -aG docker alice',
            'path'    => [ '/usr/sbin', '/usr/bin', '/bin'],
            'unless'  => 'getent group docker | cut -d \':\' -f 4 | tr \',\' \'\n\' | grep -q \'^alice$\''
          ) }

          it { is_expected.to contain_exec('Add user bob to docker group').with(
            'command' => 'usermod -aG docker bob',
            'path'    => [ '/usr/sbin', '/usr/bin', '/bin'],
            'unless'  => 'getent group docker | cut -d \':\' -f 4 | tr \',\' \'\n\' | grep -q \'^bob$\''
          ) }

          it { is_expected.to contain_user('alice').that_comes_before('Exec[Add user alice to docker group]') }
          it { is_expected.to contain_group('docker').that_comes_before('Exec[Add user alice to docker group]') }

          it { is_expected.to contain_user('bob').that_comes_before('Exec[Add user bob to docker group]') }
          it { is_expected.to contain_group('docker').that_comes_before('Exec[Add user bob to docker group]') }
          it { is_expected.to contain_user('alice').that_comes_before('Class[docker]') }
          it { is_expected.to contain_user('bob').that_comes_before('Class[docker]') }
        end
      end
    end
  end
end
