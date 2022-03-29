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

          it { is_expected.to contain_group('docker').with(
            'members' => []
          ) }

          it { is_expected.to contain_class('profiles::docker').with(
            'users' => []
          ) }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_group('docker').that_comes_before('Class[docker]') }
        end

        context "with users => myuser" do
          let(:params) { {
            'users' => 'myuser'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_user('myuser') }
          it { is_expected.to contain_group('docker').with(
            'members' => ['myuser']
          ) }

          it { is_expected.to contain_user('myuser').that_comes_before('Class[docker]') }
          it { is_expected.to contain_group('docker').that_comes_before('Class[docker]') }
        end

        context "with users => ['alice', 'bob']" do
          let(:params) { {
            'users' => ['alice', 'bob']
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('docker').with(
            'use_upstream_package_source' => false,
            'docker_users'                => []
          ) }

          it { is_expected.to contain_user('alice') }
          it { is_expected.to contain_user('bob') }
          it { is_expected.to contain_group('docker').with(
            'members' => ['alice', 'bob']
          ) }

          it { is_expected.to contain_user('alice').that_comes_before('Class[docker]') }
          it { is_expected.to contain_user('bob').that_comes_before('Class[docker]') }
        end
      end
    end
  end
end
