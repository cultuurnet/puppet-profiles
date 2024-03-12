describe 'profiles::mysql::root_my_cnf' do
  context "with title localhost" do
    let(:title) { 'localhost' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without parameters" do
          let(:params) { { } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__root_my_cnf('localhost').with(
            'database_user'    => 'root',
            'databse_password' => nil
          ) }

          it { is_expected.to contain_file('localhost my.cnf').with(
            'ensure' => 'file',
            'path'   => '/root/.my.cnf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('localhost my.cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=localhost\n$/) }
        end

        context "with database_user => admin and database_password => test" do
          let(:params) { {
            'database_user'     => 'admin',
            'database_password' => 'test',
          } }

          it { is_expected.to contain_file('localhost my.cnf').with_content(/^\[client\]\nuser=admin\npassword='test'\nhost=localhost\n$/) }
        end
      end
    end
  end

  context "with title db.example.com" do
    let(:title) { 'db.example.com' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without parameters" do
          let(:params) { { } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__root_my_cnf('db.example.com').with(
            'database_user'    => 'root',
            'databse_password' => nil
          ) }

          it { is_expected.to contain_file('db.example.com my.cnf').with(
            'ensure' => 'file',
            'path'   => '/root/.my.cnf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('db.example.com my.cnf').with_content(/^\[client\]\nuser=root\npassword=''\nhost=db.example.com\n$/) }
        end

        context "with database_user => admin and database_password => test" do
          let(:params) { {
            'database_user'     => 'admin',
            'database_password' => 'test',
          } }

          it { is_expected.to contain_file('db.example.com my.cnf').with_content(/^\[client\]\nuser=admin\npassword='test'\nhost=db.example.com\n$/) }
        end
      end
    end
  end
end
