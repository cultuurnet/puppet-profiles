describe 'profiles::ssh_authorized_keys' do
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

          context "with keys => { foo => { tags => [publiq, example], keys => { type => ssh-rsa, key => abcd1234 } }, bar => { tags => publiq, keys => [{ type => ssh-rsa, key => efgh5678 }, { type => ssh-ed25519, key => ijkl9012 }] }, baz => { tags => acme, keys => {type => ssh-rsa, key => efgh5678} } }" do
            let(:params) {
              {
                'keys' => {
                  'foo' => { 'tags' => ['publiq', 'example'], 'keys' => { 'type' => 'ssh-rsa', 'key' => 'abcd1234' } },
                  'bar' => { 'tags' => 'publiq', 'keys' => [{ 'type' => 'ssh-rsa', 'key' => 'efgh5678' }, { 'type' => 'ssh-ed25519', 'key' => 'ijkl9012' }] },
                  'baz' => { 'tags' => 'acme', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678' } }
                }
              }
            }

            it { is_expected.to contain_ssh_authorized_key('foo').with(
              'user' => 'ubuntu',
              'type' => 'ssh-rsa',
              'key'  => 'abcd1234',
              'tag'  => ['publiq', 'example']
            ) }

            it { is_expected.to contain_ssh_authorized_key('bar 1').with(
              'user' => 'ubuntu',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'publiq'
            ) }

            it { is_expected.to contain_ssh_authorized_key('bar 2').with(
              'user' => 'ubuntu',
              'type' => 'ssh-ed25519',
              'key'  => 'ijkl9012',
              'tag'  => 'publiq'
            ) }

            it { is_expected.to contain_ssh_authorized_key('baz').with(
              'user' => 'ubuntu',
              'type' => 'ssh-rsa',
              'key'  => 'efgh5678',
              'tag'  => 'acme'
            ) }
          end

          context "with keys => { foo => { tags => [publiq, example], keys => { type => ssh-rsa, key => abcd1234 } } } and user => bla" do
            let(:params) {
              {
                'keys' => {
                  'foo' => { 'tags' => ['publiq', 'example'], 'keys' => { 'type' => 'ssh-rsa', 'key' => 'abcd1234' } },
                },
                'user' => 'bla'
              }
            }

            it { is_expected.to contain_ssh_authorized_key('foo').with(
              'user' => 'bla',
              'type' => 'ssh-rsa',
              'key'  => 'abcd1234',
              'tag'  => ['publiq', 'example']
            ) }
          end
        end

        context "not on AWS EC2" do
          context "with keys => { baz => { tags => acme, keys => {type => ssh-rsa, key => efgh5678} } }" do
            let(:params) {
              {
                'keys' => {
                  'baz' => { 'tags' => 'acme', 'keys' => { 'type' => 'ssh-rsa', 'key' => 'efgh5678' } }
                }
              }
            }

            it { is_expected.to contain_ssh_authorized_key('baz').with(
              'user' => 'vagrant',
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
