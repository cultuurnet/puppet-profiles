describe 'profiles::mysql::app_user' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title foobar" do
        let(:title) { 'foobar' }

        context "with parameters user => myuser, database => mydb and password => mypassword" do
          let(:params) { {
            'user'     => 'myuser',
            'database' => 'mydb',
            'password' => 'mypassword'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__app_user('foobar').with(
            'user'     => 'myuser',
            'database' => 'mydb',
            'password' => 'mypassword',
            'ensure'   => 'present',
            'table'    => '*',
            'readonly' => false,
            'remote'   => false
          ) }

          it { is_expected.to contain_mysql_user('myuser@127.0.0.1').with(
            'ensure'        => 'present',
            'password_hash' => '*FABE5482D5AADF36D028AC443D117BE1180B9725'
          ) }

          it { is_expected.to contain_mysql_grant('myuser@127.0.0.1/mydb.*').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['ALL'],
            'table'      => 'mydb.*',
            'user'       => 'myuser@127.0.0.1',
          ) }

          it { is_expected.to contain_mysql_grant('myuser@127.0.0.1/mydb.*').that_requires('Mysql_user[myuser@127.0.0.1]') }
        end

        context "with parameters user => testuser, database => testdb, password => testpassword, table => test, readonly => true and remote => true" do
          let(:params) { {
            'user'     => 'testuser',
            'database' => 'testdb',
            'password' => 'testpassword',
            'table'    => 'test',
            'readonly' => true,
            'remote'   => true
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__mysql__app_user('foobar').with(
            'user'     => 'testuser',
            'database' => 'testdb',
            'password' => 'testpassword',
            'ensure'   => 'present',
            'table'    => 'test',
            'readonly' => true,
            'remote'   => true
          ) }

          it { is_expected.to contain_mysql_user('testuser@%').with(
            'ensure'        => 'present',
            'password_hash' => '*9F69E47E519D9CA02116BF5796684F7D0D45F8FA'
          ) }

          it { is_expected.to contain_mysql_grant('testuser@%/testdb.test').with(
            'ensure'     => 'present',
            'options'    => ['GRANT'],
            'privileges' => ['READ', 'SHOW VIEW'],
            'table'      => 'testdb.test',
            'user'       => 'testuser@%',
          ) }

          it { is_expected.to contain_mysql_grant('testuser@%/testdb.test').that_requires('Mysql_user[testuser@%]') }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'user'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'password'/) }
        end
      end

      context "with title baz" do
        let(:title) { 'baz' }

        context "with parameters user => nouser, ensure => absent, database => nodb and password => nopassword" do
          let(:params) { {
            'user'     => 'nouser',
            'ensure'   => 'absent',
            'database' => 'nodb',
            'password' => 'nopassword'
          } }

          it { is_expected.to contain_mysql_user('nouser@127.0.0.1').with(
            'ensure'        => 'absent'
          ) }

          it { is_expected.not_to contain_mysql_grant('nouser@127.0.0.1/nodb.*') }
        end
      end
    end
  end
end
