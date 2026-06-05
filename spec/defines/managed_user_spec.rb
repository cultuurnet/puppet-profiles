describe 'profiles::managed_user' do
  let(:title) { 'publiq-first' }
  let(:pre_condition) { 'group { "managed_users": ensure => present }' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with sudo access" do
        let(:params) { {
          'key_name' => 'publiq first key',
          'keys'     => { 'type' => 'ssh-rsa', 'key' => 'abcd' },
          'uid'      => 5000,
          'sudo'     => true,
          'tags'     => 'publiq'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('publiq-first').with(
          'ensure' => 'present',
          'tag'    => 'publiq'
        ).that_comes_before('User[publiq-first]') }

        it { is_expected.to contain_user('publiq-first').with(
          'ensure'         => 'present',
          'gid'            => 'publiq-first',
          'groups'         => ['managed_users', 'sudo'],
          'home'           => '/home/publiq-first',
          'managehome'     => true,
          'purge_ssh_keys' => true,
          'shell'          => '/bin/bash',
          'uid'            => 5000,
          'tag'            => 'publiq'
        ).that_requires('Group[managed_users]').that_requires('Group[publiq-first]') }

        it { is_expected.to contain_ssh_authorized_key('publiq first key for publiq-first').with(
          'user' => 'publiq-first',
          'type' => 'ssh-rsa',
          'key'  => 'abcd',
          'tag'  => 'publiq'
        ).that_requires('User[publiq-first]') }
      end

      context "without sudo access and with multiple keys" do
        let(:params) { {
          'key_name' => 'publiq first key',
          'keys'     => [
            { 'type' => 'ssh-rsa', 'key' => 'abcd' },
            { 'type' => 'ssh-ed25519', 'key' => 'efgh' }
          ],
          'uid'      => 5001,
          'tags'     => ['publiq', 'example']
        } }

        it { is_expected.to contain_user('publiq-first').with_groups(['managed_users']) }
        it { is_expected.to contain_ssh_authorized_key('publiq first key 1 for publiq-first') }
        it { is_expected.to contain_ssh_authorized_key('publiq first key 2 for publiq-first') }
      end
    end
  end
end
