describe 'profiles::jenkins::controller::configuration::private_key' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_file('Jenkins .ssh config directory').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/jenkins/.ssh',
          'owner'  => 'jenkins',
          'group'  => 'jenkins',
          'mode'   => '0500'
        ) }

        it { is_expected.to contain_file('Jenkins private key').with(
          'ensure' => 'absent',
          'path'   => '/var/lib/jenkins/.ssh/id_jenkins'
        ) }

        it { is_expected.not_to contain_exec('Jenkins public key') }
      end

      context 'with key => abc123' do
        let(:params) { {
          'key' => 'abc123'
        } }

        it { is_expected.to contain_group('jenkins') }
        it { is_expected.to contain_user('jenkins') }

        it { is_expected.to contain_file('Jenkins .ssh config directory').with(
          'ensure' => 'directory',
          'path'   => '/var/lib/jenkins/.ssh',
          'owner'  => 'jenkins',
          'group'  => 'jenkins',
          'mode'   => '0500'
        ) }

        it { is_expected.to contain_file('Jenkins private key').with(
          'ensure'  => 'file',
          'path'    => '/var/lib/jenkins/.ssh/id_jenkins',
          'content' => 'abc123',
          'owner'   => 'jenkins',
          'group'   => 'jenkins',
          'mode'    => '0400'
        ) }

        it { is_expected.to contain_exec('Jenkins public key').with(
          'command'     => '/usr/bin/ssh-keygen -y -f /var/lib/jenkins/.ssh/id_jenkins > /var/lib/jenkins/.ssh/id_jenkins.pub',
          'user'        => 'jenkins',
          'refreshonly' => true
        ) }

        it { expect(exported_resources).not_to contain_ssh_authorized_key('Jenkins public key') }

        it { is_expected.to contain_exec('Jenkins public key').that_requires('Group[jenkins]') }
        it { is_expected.to contain_exec('Jenkins public key').that_requires('User[jenkins]') }
        it { is_expected.to contain_exec('Jenkins public key').that_requires('File[Jenkins .ssh config directory]') }
        it { is_expected.to contain_exec('Jenkins public key').that_subscribes_to('File[Jenkins private key]') }
      end

      context 'on node foo.example.com' do
        let(:node) { 'foo.example.com' }
        let(:trusted_facts) { {
          'certname' => 'foo.example.com',
          'hostname' => 'foo',
          'domain'   => 'example.com'
        } }

        context 'with fact jenkins_pubkey => { type => ssh-ed25519, key => abcd1234 } on EC2' do
          let(:facts) {
            super().merge({
              'jenkins_pubkey' => { 'type' => 'ssh-ed25519', 'key' => 'abcd1234' },
              'ec2_metadata'   => true
            })
          }

          it { expect(exported_resources).to contain_ssh_authorized_key('Jenkins public key (foo)').with(
            'user' => 'ubuntu',
            'type' => 'ssh-ed25519',
            'key'  => 'abcd1234',
            'tag'  => ['jenkins']
          ) }
        end
      end
    end
  end
end
