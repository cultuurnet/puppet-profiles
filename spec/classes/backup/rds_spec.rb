describe 'profiles::backup::rds' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/rds.yaml' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('Profiles::Backup::Rds').with(
            'backupdir'                   => '/data/rdsbackups',
            'offsite_storage_public_keys' => {},
            'lvm'                         => false,
            'volume_group'                => nil,
            'volume_size'                 => nil,
            'extra_rds_configs'           => {}
          ) }
        end

        context 'with offsite_storage_public_keys => { foo => { type => ed25519, key => abcd1234 } }' do
          let(:params) { {
            'offsite_storage_public_keys' => { 'foo' => { 'type' => 'ed25519', 'key' => 'abcd1234' } }
          } }

          it { expect(exported_resources).to contain_ssh_authorized_key('RDS backup public key foo').with(
            'user' => 'ubuntu',
            'type' => 'ed25519',
            'key'  => 'abcd1234',
            'tag'  => ['backup::rds', 'bastion']
          ) }
        end

        context 'with Terraform, offsite_storage_public_keys => and extra configs' do
          let(:params) {{
            'backupdir' => '/tmp/rds_test',
            'extra_rds_configs' => {
              'extra1' => {
                'rds::host'     => 'extra.example',
                'rds::user'     => 'euser',
                'rds::password' => 'epwd',
                'rds::database' => 'edb',
              }
            }
          }}

          it 'compiles, creates file and writes merged YAML' do
            is_expected.to compile.with_all_deps

            # Resource attributes
            expect(subject).to contain_file('/tmp/rds_test/rds_servers.yml').with(
              'ensure' => 'file',
              'owner'  => 'ubuntu',
              'group'  => 'ubuntu',
              'mode'   => '0600'
            )

            expect(subject).to contain_file('/tmp/rds_test/rds_servers.yml').with_content(
              %r{app1:\n\s+host: db1.example\n\s+user: tuser1\n\s+password: tpwd1\n\s+database: tdb1}
            )

            expect(subject).to contain_file('/tmp/rds_test/rds_servers.yml').with_content(
              %r{app2:\n\s+host: db2.example\n\s+user: tuser2\n\s+password: tpwd2\n\s+database: tdb2}
            )

            expect(subject).to contain_file('/tmp/rds_test/rds_servers.yml').with_content(
              %r{extra1:\n\s+host: extra.example\n\s+user: euser\n\s+password: epwd\n\s+database: edb}
            )
          end
        end
      end
    end
  end
end
