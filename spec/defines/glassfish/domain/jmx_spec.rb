describe 'profiles::glassfish::domain::jmx' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar-api" do
        let(:title) { 'foobar-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__glassfish__domain__jmx('foobar-api').with(
            'ensure'   => 'present',
            'portbase' => 4800
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.port=9003').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.port=9003',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.local.only=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.local.only=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.authenticate=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.authenticate=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.ssl=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.ssl=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Djava.rmi.server.hostname=127.0.0.1').with(
            'ensure'       => 'present',
            'option'       => '-Djava.rmi.server.hostname=127.0.0.1',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }
        end

        context 'with ensure => absent and portbase => 14800' do
          let(:params) { {
            'ensure'   => 'absent',
            'portbase' => 14800
          } }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote').with(
            'ensure'       => 'absent',
            'option'       => '-Dcom.sun.management.jmxremote',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.port=9003').with(
            'ensure'       => 'absent',
            'option'       => '-Dcom.sun.management.jmxremote.port=9003',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.local.only=false').with(
            'ensure'       => 'absent',
            'option'       => '-Dcom.sun.management.jmxremote.local.only=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.authenticate=false').with(
            'ensure'       => 'absent',
            'option'       => '-Dcom.sun.management.jmxremote.authenticate=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Dcom.sun.management.jmxremote.ssl=false').with(
            'ensure'       => 'absent',
            'option'       => '-Dcom.sun.management.jmxremote.ssl=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -Djava.rmi.server.hostname=127.0.0.1').with(
            'ensure'       => 'absent',
            'option'       => '-Djava.rmi.server.hostname=127.0.0.1',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '14800'
          ) }
        end
      end

      context "title baz-api" do
        let(:title) { 'baz-api' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Dcom.sun.management.jmxremote').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Dcom.sun.management.jmxremote.port=9003').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.port=9003',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Dcom.sun.management.jmxremote.local.only=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.local.only=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Dcom.sun.management.jmxremote.authenticate=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.authenticate=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Dcom.sun.management.jmxremote.ssl=false').with(
            'ensure'       => 'present',
            'option'       => '-Dcom.sun.management.jmxremote.ssl=false',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }

          it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -Djava.rmi.server.hostname=127.0.0.1').with(
            'ensure'       => 'present',
            'option'       => '-Djava.rmi.server.hostname=127.0.0.1',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass',
            'portbase'     => '4800'
          ) }
        end
      end
    end
  end
end
