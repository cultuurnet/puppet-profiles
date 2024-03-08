describe 'profiles::mysql::root_my_cnf' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::root_my_cnf').with(
          'root_user'     => 'root',
          'root_password' => nil,
          'host'          => 'localhost'
        ) }

        it { is_expected.to contain_file('root_my_cnf').with(
          'ensure' => 'file',
          'path'   => '/root/.my.cnf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0400'
        ) }

        it { is_expected.to contain_file('root_my_cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=localhost\n$/) }
      end

      context "with root_user => admin, root_password => test, host => db.example.com" do
        let(:params) { {
          'root_user'     => 'admin',
          'root_password' => 'test',
          'host'          => 'db.example.com'
        } }

        it { is_expected.to contain_file('root_my_cnf').with_content(/^\[client\]\nuser=admin\npassword='test'\nhost=db.example.com\n$/) }
      end
    end
  end
end
