describe 'profiles::vault::policy' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foo" do
        let(:title) { 'foo' }

        context 'with policy => path "kv/*" { capabilities = ["read"] }' do
          let(:params) { {
            'policy' => 'path "kv/*" { capabilities = ["read"] }'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__vault__policy('foo').with(
            'policy'             => 'path "kv/*" { capabilities = ["read"] }',
            'policies_directory' => '/etc/vault.d/policies'
          ) }

          it { is_expected.to contain_group('vault') }
          it { is_expected.to contain_user('vault') }

          it { is_expected.to contain_file('vault policy foo').with(
            'ensure'  => 'file',
            'path'    => '/etc/vault.d/policies/foo.hcl',
            'owner'   => 'vault',
            'group'   => 'vault',
            'content' => 'path "kv/*" { capabilities = ["read"] }'
          ) }

          it { is_expected.to contain_exec('vault_write_policy foo').with(
            'command'     => '/usr/bin/vault policy write foo /etc/vault.d/policies/foo.hcl',
            'user'        => 'vault',
            'refreshonly' => true,
            'logoutput' => 'on_failure'
          ) }

          it { is_expected.to contain_file('vault policy foo').that_requires('Group[vault]') }
          it { is_expected.to contain_file('vault policy foo').that_requires('User[vault]') }
          it { is_expected.to contain_exec('vault_write_policy foo').that_requires('User[vault]') }
          it { is_expected.to contain_exec('vault_write_policy foo').that_subscribes_to('File[vault policy foo]') }
        end

        context 'with policy => path "test/*" { capabilities = ["list"] } and policies_directory => /tmp' do
          let(:params) { {
            'policy'             => 'path "test/*" { capabilities = ["list"] }',
            'policies_directory' => '/tmp'
          } }

          it { is_expected.to contain_file('vault policy foo').with(
            'ensure'  => 'file',
            'path'    => '/tmp/foo.hcl',
            'owner'   => 'vault',
            'group'   => 'vault',
            'content' => 'path "test/*" { capabilities = ["list"] }'
          ) }
        end

        context 'without parameters' do
          let(:params) { { } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'policy'/) }
        end
      end

      context "title bar" do
        let(:title) { 'bar' }

        context 'with policy => path "example/*" { capabilities = ["read", "list"] }' do
          let(:params) { {
            'policy' => 'path "example/*" { capabilities = ["read", "list"] }'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('vault policy bar').with(
            'ensure'  => 'file',
            'path'    => '/etc/vault.d/policies/bar.hcl',
            'owner'   => 'vault',
            'group'   => 'vault',
            'content' => 'path "example/*" { capabilities = ["read", "list"] }'
          ) }
        end
      end
    end
  end
end
