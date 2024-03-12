describe 'profiles::mysql::my_cnf' do
  context "with title root" do
    let(:title) { 'root' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without parameters" do
          let(:params) { { } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__my_cnf('root').with(
            'database_user'    => 'root',
            'databse_password' => nil,
            'host'             => 'localhost'
          ) }

          it { is_expected.to contain_file('root my.cnf').with(
            'ensure' => 'file',
            'path'   => '/root/.my.cnf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('root my.cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=localhost\n$/) }
        end

        context "with database_user => admin, database_password => test, host => db.example.com" do
          let(:params) { {
            'database_user'     => 'admin',
            'database_password' => 'test',
            'host'              => 'db.example.com'
          } }

          it { is_expected.to contain_file('root my.cnf').with_content(/^\[client\]\nuser=admin\npassword='test'\nhost=db.example.com\n$/) }
        end
      end
    end
  end

  context "with title ubuntu" do
    let(:title) { 'ubuntu' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without parameters" do
          let(:params) { { } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__my_cnf('ubuntu').with(
            'database_user'    => 'root',
            'databse_password' => nil,
            'host'             => 'localhost'
          ) }

          it { is_expected.to contain_group('ubuntu') }
          it { is_expected.to contain_user('ubuntu') }

          it { is_expected.to contain_file('ubuntu my.cnf').with(
            'ensure' => 'file',
            'path'   => '/home/ubuntu/.my.cnf',
            'owner'  => 'ubuntu',
            'group'  => 'ubuntu',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('ubuntu my.cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=localhost\n$/) }

          it { is_expected.to contain_file('ubuntu my.cnf').that_requires('Group[ubuntu]') }
          it { is_expected.to contain_file('ubuntu my.cnf').that_requires('User[ubuntu]') }
        end

        context "with database_user => admin, database_password => test, host => db.example.com" do
          let(:params) { {
            'database_user'     => 'admin',
            'database_password' => 'test',
            'host'              => 'db.example.com'
          } }

          it { is_expected.to contain_file('ubuntu my.cnf').with_content(/^\[client\]\nuser=admin\npassword='test'\nhost=db.example.com\n$/) }
        end
      end
    end
  end
end
