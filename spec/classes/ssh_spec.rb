describe 'profiles::ssh' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('Profiles::Ssh').with(
          'authorized_keys'      => {},
          'authorized_keys_tags' => [],
          'mfa'                  => false,
          'manage_admin_user_authorized_keys' => true,
          'mfa_enforced'         => false
        ) }

        it { is_expected.to contain_class('Profiles::Ssh::Mfa').with(
          'enabled'              => false,
          'enforced'             => false,
          'authorized_keys'      => {},
          'authorized_keys_tags' => []
        ) }

        it { is_expected.to contain_package('openssh-server').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_profiles__ssh__sshd_config('PermitRootLogin').with(
          'ensure' => 'present',
          'value'  => 'no'
        ) }

        it { is_expected.to contain_profiles__ssh__sshd_config('PubkeyAcceptedKeyTypes').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_service('ssh').with(
          'ensure' => 'running',
          'enable' => true
        ) }

        it { is_expected.to contain_class('Profiles::Ssh::Service') }

        it { is_expected.to contain_file('/etc/ssh/sshd_config.d').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_profiles__ssh__sshd_config('Include').with_value('/etc/ssh/sshd_config.d/*.conf') }

        it { is_expected.to contain_file('ssh_known_hosts').with(
          'ensure' => 'file',
          'path'   => '/etc/ssh/ssh_known_hosts',
          'mode'   => '0644'
        ) }

        it { is_expected.to contain_resources('sshkey').with(
          'purge' => true
        ) }

        it { is_expected.to contain_resources('ssh_authorized_key').with(
          'purge' => true
        ) }

        it { is_expected.to contain_firewall('100 accept SSH traffic') }

        it { is_expected.to contain_class('Profiles::Ssh::Authorized_keys').with(
          'keys'                              => {},
          'manage_admin_user_authorized_keys' => true
        ) }

        it { is_expected.to contain_profiles__ssh__sshd_config('PermitRootLogin').that_notifies('Class[Profiles::Ssh::Service]') }
        it { is_expected.to contain_profiles__ssh__sshd_config('PubkeyAcceptedKeyTypes').that_notifies('Class[Profiles::Ssh::Service]') }
        it { is_expected.to contain_profiles__ssh__sshd_config('Include').that_notifies('Class[Profiles::Ssh::Service]') }
        it { is_expected.to contain_package('openssh-server').that_notifies('Class[Profiles::Ssh::Service]') }
      end

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with mfa enabled' do
          let(:authorized_keys) { {
            'Publiq First User' => {
              'active' => true,
              'tags'   => 'publiq',
              'keys'   => {
                'type' => 'ssh-rsa',
                'key'  => 'abcd'
              }
            }
          } }
          let(:params) { {
            'authorized_keys'      => authorized_keys,
            'authorized_keys_tags' => 'publiq',
            'mfa'                  => true,
            'mfa_enforced'         => true
          } }

          it { is_expected.to contain_class('Profiles::Ssh::Mfa').with(
            'enabled'              => true,
            'enforced'             => true,
            'authorized_keys'      => authorized_keys,
            'authorized_keys_tags' => 'publiq'
          ) }

          it { is_expected.to contain_class('Profiles::Ssh::Mfa').that_notifies('Class[Profiles::Ssh::Service]') }
        end

        context 'on AWS EC2' do
          let(:facts) {
            super().merge({ 'ec2_metadata' => 'true'})
          }

          context "with authorized_keys_tags => publiq" do
            let(:params) { { 'authorized_keys_tags' => 'publiq' } }

            it { is_expected.to contain_ssh_authorized_key('publiq first key ubuntu') }
            it { is_expected.to contain_ssh_authorized_key('publiq second key ubuntu') }
            it { is_expected.to contain_ssh_authorized_key('publiq first key') }
            it { is_expected.to contain_ssh_authorized_key('publiq second key') }

            it { is_expected.to have_ssh_authorized_key_resource_count(4) }
          end

          context "with authorized_keys_tags => publiq and manage_admin_user_authorized_keys => false" do
            let(:params) { {
              'authorized_keys_tags' => 'publiq',
              'manage_admin_user_authorized_keys' => false
            } }

            it { is_expected.not_to contain_ssh_authorized_key('publiq first key ubuntu') }
            it { is_expected.not_to contain_ssh_authorized_key('publiq second key ubuntu') }
            it { is_expected.to contain_ssh_authorized_key('publiq first key') }
            it { is_expected.to contain_ssh_authorized_key('publiq second key') }

            it { is_expected.to have_ssh_authorized_key_resource_count(2) }
          end

          context "with authorized_keys_tags => acme" do
            let(:params) { { 'authorized_keys_tags' => 'acme' } }

            it { is_expected.not_to contain_ssh_authorized_key('acme first key ubuntu') }
            it { is_expected.not_to contain_ssh_authorized_key('acme first key') }

            it { is_expected.to have_ssh_authorized_key_resource_count(0) }
          end
        end
      end
    end
  end
end
