describe 'profiles::vault::trusted_certificate' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title node01.example.com" do
        let(:title) { 'node01.example.com' }

        context 'with certificate => abc' do
          let(:params) { {
            'certificate' => 'abc'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__vault__trusted_certificate('node01.example.com').with(
            'trusted_certs_directory' => '/etc/vault.d/trusted_certs',
            'policies'                => 'puppet_certificate',
            'certificate'             => 'abc'
          ) }

          it { is_expected.to contain_group('vault') }
          it { is_expected.to contain_user('vault') }

          it { is_expected.to contain_file('vault trusted cert node01.example.com').with(
            'ensure'  => 'file',
            'path'    => '/etc/vault.d/trusted_certs/node01.example.com.pem',
            'owner'   => 'vault',
            'group'   => 'vault',
            'content' => 'abc'
          ) }

          it { is_expected.to contain_exec('vault_trust_cert node01.example.com').with(
            'command'   => '/usr/bin/vault write auth/cert/certs/node01.example.com display_name=node01.example.com policies=puppet_certificate certificate=@/etc/vault.d/trusted_certs/node01.example.com.pem',
            'user'      => 'vault',
            'unless'    => '/usr/bin/vault read auth/cert/certs/node01.example.com',
            'logoutput' => 'on_failure'
          ) }

          it { is_expected.to contain_file('vault trusted cert node01.example.com').that_requires('Group[vault]') }
          it { is_expected.to contain_file('vault trusted cert node01.example.com').that_requires('User[vault]') }
          it { is_expected.to contain_exec('vault_trust_cert node01.example.com').that_requires('User[vault]') }
          it { is_expected.to contain_exec('vault_trust_cert node01.example.com').that_requires('File[vault trusted cert node01.example.com]') }
        end

        context 'with trusted_certs_directory => /tmp policies => [foo, bar] and certificate => xyz' do
          let(:params) { {
            'trusted_certs_directory' => '/tmp',
            'policies'                => ['foo', 'bar'],
            'certificate'             => 'xyz'
          } }

          it { is_expected.to contain_file('vault trusted cert node01.example.com').with(
            'ensure' => 'file',
            'path'   => '/tmp/node01.example.com.pem',
            'owner'  => 'vault',
            'group'  => 'vault',
            'content' => 'xyz'
          ) }

          it { is_expected.to contain_exec('vault_trust_cert node01.example.com').with(
            'command'   => '/usr/bin/vault write auth/cert/certs/node01.example.com display_name=node01.example.com policies=foo,bar certificate=@/tmp/node01.example.com.pem',
            'user'      => 'vault',
            'unless'    => '/usr/bin/vault read auth/cert/certs/node01.example.com',
            'logoutput' => 'on_failure'
          ) }
        end
      end

      context "title node02.example.com" do
        let(:title) { 'node02.example.com' }

        context 'with certificate def' do
          let(:params) { {
            'certificate' => 'def'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('vault trusted cert node02.example.com').with(
            'ensure'  => 'file',
            'path'    => '/etc/vault.d/trusted_certs/node02.example.com.pem',
            'owner'   => 'vault',
            'group'   => 'vault',
            'content' => 'def'
          ) }

          it { is_expected.to contain_exec('vault_trust_cert node02.example.com').with(
            'command'   => '/usr/bin/vault write auth/cert/certs/node02.example.com display_name=node02.example.com policies=puppet_certificate certificate=@/etc/vault.d/trusted_certs/node02.example.com.pem',
            'user'      => 'vault',
            'unless'    => '/usr/bin/vault read auth/cert/certs/node02.example.com',
            'logoutput' => 'on_failure'
          ) }
        end
      end
    end
  end
end
