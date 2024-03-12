describe 'profiles::mysql::rds' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with hieradata" do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to contain_file('mysqld_version_external_fact').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => 'mysqld_version=8.0.33'
        ) }

        it { is_expected.to contain_profiles__mysql__root_my_cnf('myrdshost.example.com').with(
          'database_user'     => 'admin',
          'database_password' => 'mypass'
        ) }
      end

      context "without hieradata" do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.not_to contain_file('mysqld_version_external_fact') }
        it { is_expected.to have_profiles__mysql__my_cnf_resource_count(0) }
      end
    end
  end
end
