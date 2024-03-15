describe 'profiles::glassfish::domain::newrelic' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar-api" do
        let(:title) { 'foobar-api' }

        context 'in the production environment' do
          let(:environment) { 'production' }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_profiles__glassfish__domain__newrelic('foobar-api').with(
              'ensure'      => 'present',
              'license_key' => nil,
              'app_name'    => 'foobar-api-production',
              'portbase'    => 4800
            ) }

            it { is_expected.to contain_class('profiles::newrelic::java') }

            it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -javaagent:/opt/newrelic/newrelic.jar').with(
              'ensure'       => 'present',
              'option'       => '-javaagent:/opt/newrelic/newrelic.jar',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_systemproperty('Domain foobar-api newrelic.config.file').with(
              'name'         => 'newrelic.config.file',
              'ensure'       => 'present',
              'value'        => '/opt/payara/glassfish/domains/foobar-api/config/newrelic.yml',
              'portbase'     => '4800',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass'
            ) }

            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with(
              'ensure'       => 'file',
              'path'         => '/opt/payara/glassfish/domains/foobar-api/config/newrelic.yml',
              'owner'        => 'glassfish',
              'group'        => 'glassfish'
            ) }

            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with_content(/^\s*license_key: \s*$/) }
            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with_content(/^\s*app_name: foobar-api-production\s*$/) }
            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with_content(/^\s*log_file_path: \/opt\/payara\/glassfish\/domains\/foobar-api\/logs\s*$/) }

            it { is_expected.to contain_systemproperty('Domain foobar-api newrelic.config.file').that_requires('File[Domain foobar-api newrelic config file]') }
            it { is_expected.to contain_class('profiles::newrelic::java').that_comes_before('Jvmoption[Domain foobar-api jvmoption -javaagent:/opt/newrelic/newrelic.jar]') }
          end

          context 'with license_key => xyz, app_name => my_app_name and portbase => 5000' do
            let(:params) { {
              'license_key' => 'xyz',
              'app_name'    => 'my_app_name',
              'portbase'    => 5000
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -javaagent:/opt/newrelic/newrelic.jar').with(
              'portbase'     => '5000'
            ) }

            it { is_expected.to contain_systemproperty('Domain foobar-api newrelic.config.file').with(
              'portbase'     => '5000'
            ) }

            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with_content(/^\s*license_key: xyz\s*$/) }
            it { is_expected.to contain_file('Domain foobar-api newrelic config file').with_content(/^\s*app_name: my_app_name\s*$/) }
          end
        end

        context 'with ensure => absent and portbase => 14800' do
          let(:params) { {
            'ensure'   => 'absent',
            'portbase' => 14800
          } }

          it { is_expected.to contain_jvmoption('Domain foobar-api jvmoption -javaagent:/opt/newrelic/newrelic.jar').with(
            'ensure'       => 'absent',
            'option'       => '-javaagent:/opt/newrelic/newrelic.jar',
            'portbase'     => '14800',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass'
          ) }

          it { is_expected.to contain_systemproperty('Domain foobar-api newrelic.config.file').with(
            'ensure'       => 'absent',
            'value'        => '/opt/payara/glassfish/domains/foobar-api/config/newrelic.yml',
            'portbase'     => '14800',
            'user'         => 'glassfish',
            'passwordfile' => '/home/glassfish/asadmin.pass'
          ) }

          it { is_expected.to contain_file('Domain foobar-api newrelic config file').with(
            'ensure'       => 'absent',
            'path'         => '/opt/payara/glassfish/domains/foobar-api/config/newrelic.yml'
          ) }
        end
      end

      context "title baz-api" do
        let(:title) { 'baz-api' }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_profiles__glassfish__domain__newrelic('baz-api').with(
              'ensure'      => 'present',
              'license_key' => nil,
              'app_name'    => 'baz-api-acceptance',
              'portbase'    => 4800
            ) }

            it { is_expected.to contain_class('profiles::newrelic::java') }

            it { is_expected.to contain_jvmoption('Domain baz-api jvmoption -javaagent:/opt/newrelic/newrelic.jar').with(
              'ensure'       => 'present',
              'option'       => '-javaagent:/opt/newrelic/newrelic.jar',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass',
              'portbase'     => '4800'
            ) }

            it { is_expected.to contain_systemproperty('Domain baz-api newrelic.config.file').with(
              'name'         => 'newrelic.config.file',
              'ensure'       => 'present',
              'value'        => '/opt/payara/glassfish/domains/baz-api/config/newrelic.yml',
              'portbase'     => '4800',
              'user'         => 'glassfish',
              'passwordfile' => '/home/glassfish/asadmin.pass'
            ) }

            it { is_expected.to contain_file('Domain baz-api newrelic config file').with(
              'ensure'       => 'file',
              'path'         => '/opt/payara/glassfish/domains/baz-api/config/newrelic.yml',
              'owner'        => 'glassfish',
              'group'        => 'glassfish'
            ) }

            it { is_expected.to contain_file('Domain baz-api newrelic config file').with_content(/^\s*license_key: \s*$/) }
            it { is_expected.to contain_file('Domain baz-api newrelic config file').with_content(/^\s*app_name: baz-api-acceptance\s*$/) }
            it { is_expected.to contain_file('Domain baz-api newrelic config file').with_content(/^\s*log_file_path: \/opt\/payara\/glassfish\/domains\/baz-api\/logs\s*$/) }

            it { is_expected.to contain_systemproperty('Domain baz-api newrelic.config.file').that_requires('File[Domain baz-api newrelic config file]') }
          end
        end
      end
    end
  end
end
