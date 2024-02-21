describe 'profiles::deployment::versions' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title exampleproject" do
        let(:title) { 'exampleproject' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::deployment') }
          it { is_expected.not_to contain_exec('update facts due to deployment of exampleproject') }
        end

        context "with puppetdb_url => http://localhost:8080" do
          let(:params) { {
            'puppetdb_url' => 'http://localhost:8080'
          } }

          it { is_expected.to contain_exec('update facts due to deployment of exampleproject').with(
            'command'     => 'update_facts -p http://localhost:8080',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
          ) }

          it { is_expected.to contain_exec('update facts due to deployment of exampleproject').that_subscribes_to('Class[profiles::deployment]') }
        end
      end

      context "with title foobar" do
        let(:title) { 'foobar' }

        context "with puppetdb_url => http://localhost:8081" do
          let(:params) { {
            'puppetdb_url' => 'http://localhost:8081'
          } }

          it { is_expected.to contain_exec('update facts due to deployment of foobar').with(
             'command'     => 'update_facts -p http://localhost:8081',
             'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
             'refreshonly' => true
          ) }

          it { is_expected.to contain_exec('update facts due to deployment of foobar').that_subscribes_to('Class[profiles::deployment]') }
        end
      end
    end
  end
end
