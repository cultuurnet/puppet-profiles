describe 'profiles::sling::connection' do
  context 'with title => foo' do
    let(:title) { 'foo' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with type => mysql' do
          let(:params) { {
            'type' => 'mysql'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__sling__connection('foo').with(
            'type'          => 'mysql',
            'configuration' => {}
          ) }

          it { is_expected.to contain_class('profiles::sling') }

          it { is_expected.to contain_concat_fragment('foo').with(
            'target'  => '/root/.sling/env.yaml',
            'content' => "  foo:\n    type: mysql\n    user: \n    password: \n    host: 127.0.0.1\n    port: 3306\n    database: \n    tls: skip-verify\n    allow_fallback_to_plaintext: true\n",
            'order'   => 2
          ) }
        end

        context 'with type => mysql and configuration => { user => myuser, password => mypass, host => myhost.example.com, port => 13306, database => foo }' do
          let(:params) { {
            'type'          => 'mysql',
            'configuration' => {
                                 'user'     => 'myuser',
                                 'password' => 'mypass',
                                 'host'     => 'myhost.example.com',
                                 'port'     => '13306',
                                 'database' => 'foo'
                               }
          } }

          it { is_expected.to contain_concat_fragment('foo').with(
            'target'  => '/root/.sling/env.yaml',
            'content' => "  foo:\n    type: mysql\n    user: myuser\n    password: mypass\n    host: myhost.example.com\n    port: 13306\n    database: foo\n    tls: skip-verify\n    allow_fallback_to_plaintext: true\n",
            'order'   => 2
          ) }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'type'/) }
        end
      end
    end
  end

  context 'with title => bar' do
    let(:title) { 'bar' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with type => postgres and configuration => {}' do
          let(:params) { {
            'type'          => 'postgres',
            'configuration' => {}
          } }

          it { is_expected.to contain_class('profiles::sling') }

          it { is_expected.to contain_concat_fragment('bar').with(
            'target'  => '/root/.sling/env.yaml',
            'content' => "  bar:\n    type: postgres\n    user: \n    password: \n    host: 127.0.0.1\n    port: 5432\n    database: \n    sslmode: disable\n",
            'order'   => 2
          ) }
        end

        context 'with type => postgres and configuration => { user => linus, password => secret, host => 127.0.1.1 and database => mydb }' do
          let(:params) { {
            'type'          => 'postgres',
            'configuration' => {
                                 'user'     => 'linus',
                                 'password' => 'secret',
                                 'host'     => '127.0.1.1',
                                 'database' => 'mydb'
                               }
          } }

          it { is_expected.to contain_concat_fragment('bar').with(
            'target'  => '/root/.sling/env.yaml',
            'content' => "  bar:\n    type: postgres\n    user: linus\n    password: secret\n    host: 127.0.1.1\n    port: 5432\n    database: mydb\n    sslmode: disable\n",
            'order'   => 2
          ) }
        end
      end
    end
  end
end
