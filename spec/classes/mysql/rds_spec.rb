describe 'profiles::mysql::rds' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with host => rds.example.com" do
        let(:params) { {
          'host' => 'rds.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/terraform_available.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

          it { is_expected.to contain_file('mysqld_version_external_fact').with(
            'ensure'  => 'file',
            'path'    => '/etc/puppetlabs/facter/facts.d/mysqld_version.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => 'mysqld_version=8.0.33'
          ) }

          it { is_expected.to contain_profiles__mysql__root_my_cnf('rds.example.com').with(
            'database_user'     => 'admin',
            'database_password' => 'mypass'
          ) }

          it { is_expected.to contain_file('mysqld_version_external_fact').that_requires('File[/etc/puppetlabs/facter/facts.d]') }
        end

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_file('mysqld_version_external_fact') }
          it { is_expected.to have_profiles__mysql__my_cnf_resource_count(0) }
        end
      end

      context "with host => myrds.example.com" do
        let(:params) { {
          'host' => 'myrds.example.com'
        } }

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/terraform_available.yaml' }

          it { is_expected.to contain_profiles__mysql__root_my_cnf('myrds.example.com').with(
            'database_user'     => 'admin',
            'database_password' => 'mypass'
          ) }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'host'/) }
      end
    end
  end
end
