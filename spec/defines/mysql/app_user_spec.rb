describe 'profiles::mysql::app_user' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title foobar@mydb" do
        let(:title) { 'foobar@mydb' }

        context "with password => mypassword" do
          let(:params) { {
            'password' => 'mypassword'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__app_user('foobar@mydb').with(
            'user'     => 'foobar',
            'database' => 'mydb',
            'password' => 'mypassword',
            'ensure'   => 'present',
            'tables'   => '*',
            'readonly' => false,
            'remote'   => false
          ) }

          it { is_expected.to contain_mysql_user('foobar@127.0.0.1').with(
            'ensure'        => 'present',
            'password_hash' => '*FABE5482D5AADF36D028AC443D117BE1180B9725'
          ) }

          it { is_expected.to contain_mysql_grant('foobar@127.0.0.1/mydb.*').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['ALL'],
            'table'      => 'mydb.*',
            'user'       => 'foobar@127.0.0.1',
          ) }

          it { is_expected.to contain_mysql_grant('foobar@127.0.0.1/mydb.*').that_requires('Mysql_user[foobar@127.0.0.1]') }
        end

        context "with parameters user => testuser, database => testdb, password => testpassword, tables => test, readonly => true and remote => true" do
          let(:params) { {
            'user'     => 'testuser',
            'database' => 'testdb',
            'password' => 'testpassword',
            'tables'   => 'test',
            'readonly' => true,
            'remote'   => true
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_mysql_user('testuser@%').with(
            'ensure'        => 'present',
            'password_hash' => '*9F69E47E519D9CA02116BF5796684F7D0D45F8FA'
          ) }

          it { is_expected.to contain_mysql_grant('testuser@%/testdb.test').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['SELECT', 'SHOW VIEW'],
            'table'      => 'testdb.test',
            'user'       => 'testuser@%',
          ) }

          it { is_expected.to contain_mysql_grant('testuser@%/testdb.test').that_requires('Mysql_user[testuser@%]') }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'password'/) }
        end
      end

      context "with title onlyuser" do
        let(:title) { 'onlyuser' }

        context "with password => mypassword" do
          let(:params) { {
            'password' => 'mypassword'
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'database' expects a String value/) }
        end
      end

      context "with title baz@nodb" do
        let(:title) { 'baz@nodb' }

        context "with parameters user => myuser, password => testpassword, tables => [table1, table2], readonly => true and remote => true" do
          let(:params) { {
            'user'     => 'myuser',
            'password' => 'testpassword',
            'tables'   => ['table1', 'table2'],
            'readonly' => true,
            'remote'   => true
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_mysql_user('myuser@%').with(
            'ensure'        => 'present',
            'password_hash' => '*9F69E47E519D9CA02116BF5796684F7D0D45F8FA'
          ) }

          it { is_expected.to contain_mysql_grant('myuser@%/nodb.table1').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['SELECT', 'SHOW VIEW'],
            'table'      => 'nodb.table1',
            'user'       => 'myuser@%',
          ) }

          it { is_expected.to contain_mysql_grant('myuser@%/nodb.table2').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['SELECT', 'SHOW VIEW'],
            'table'      => 'nodb.table2',
            'user'       => 'myuser@%',
          ) }

          it { is_expected.to contain_mysql_grant('myuser@%/nodb.table1').that_requires('Mysql_user[myuser@%]') }
          it { is_expected.to contain_mysql_grant('myuser@%/nodb.table2').that_requires('Mysql_user[myuser@%]') }
        end

        context "with parameters user => nouser, ensure => absent, database => nodb and password => nopassword" do
          let(:params) { {
            'user'     => 'nouser',
            'ensure'   => 'absent',
            'password' => 'nopassword'
          } }

          it { is_expected.to contain_mysql_user('nouser@127.0.0.1').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_mysql_grant('nouser@127.0.0.1/nodb.*').with(
            'ensure' => 'absent'
          ) }
        end
      end
    end
  end
end
