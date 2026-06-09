describe 'profiles::ssh::authorized_keys' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Ssh_authorized_key <| |>' }

        context "on AWS EC2" do
          let(:facts) do
            super().merge({ 'ec2_metadata' => 'true'})
          end

          context "with keys => { foo => { active => true, tags => [publiq, example], keys => { type => ssh-rsa, key => abcd1234 } }, René => { active => true, tags => publiq, keys => [{ type => ssh-rsa, key => efgh5678 }, { type => ssh-ed25519, key => ijkl9012 }] }, baz => { active => false, tags => acme, keys => {type => ssh-rsa, key => efgh5678} } }" do
            let(:params) {
              {
                'keys' => {
                  'foo'  => { 'active' => true, 'tags' => ['publiq', 'example'], 'keys' => { 'type' => 'ssh-rsa', 'key' => 'abcd1234' } },
                  'René' => { 'active' => true, 'tags' => 'publiq', 'keys' => [{ 'type' => 'ssh-rsa', 'key' => 'efgh5678' }, { 'type' => 'ssh-ed25519', 'key' => 'ijkl9012' }] },
                  'baz'  => { 'active' => false, 'tags' => 'acme', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678' } }
                }
              }
            }

            it { is_expected.to contain_ssh_authorized_key('foo ubuntu').with(
              'user' => 'ubuntu',
              'type' => 'ssh-rsa',
              'key'  => 'abcd1234',
              'tag'  => ['publiq', 'example']
            ) }

            it { is_expected.to contain_ssh_authorized_key('foo').with(
              'user' => 'foo',
              'type' => 'ssh-rsa',
              'key'  => 'abcd1234',
              'tag'  => ['publiq', 'example']
            ) }

            it { is_expected.to contain_ssh_authorized_key('René 1 ubuntu').with(
              'user' => 'ubuntu',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'publiq'
            ) }

            it { is_expected.to contain_ssh_authorized_key('René 2 ubuntu').with(
              'user' => 'ubuntu',
              'type' => 'ssh-ed25519',
              'key'  => 'ijkl9012',
              'tag'  => 'publiq'
            ) }

            it { is_expected.to contain_ssh_authorized_key('René 1').with(
              'user' => 'rene',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'publiq'
            ) }

            it { is_expected.to contain_ssh_authorized_key('René 2').with(
              'user' => 'rene',
              'type' => 'ssh-ed25519',
              'key'  => 'ijkl9012',
              'tag'  => 'publiq'
            ) }

            it { is_expected.not_to contain_ssh_authorized_key('baz') }

            it { is_expected.to have_ssh_authorized_key_resource_count(6) }
          end
        end

        context 'not on AWS EC2' do
          context 'with keys => { baz => { active => true, tags => acme, keys => {type => ssh-rsa, key => efgh5678} } }' do
            let(:params) {
              {
                'keys' => {
                  'baz' => { 'active' => true, 'tags' => 'acme', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678' } }
                }
              }
            }

            it { is_expected.to contain_ssh_authorized_key('baz vagrant').with(
              'user' => 'vagrant',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'acme'
            ) }

            it { is_expected.to contain_ssh_authorized_key('baz').with(
              'user' => 'baz',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'acme'
            ) }
          end
        end
      end
    end
  end
end
