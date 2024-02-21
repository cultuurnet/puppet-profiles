describe 'profiles::glassfish' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::glassfish').with(
          'version' => '4.1.2.181'
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_class('glassfish').with(
          'install_method'      => 'package',
          'package_prefix'      => 'payara',
          'create_service'      => false,
          'create_passfile'     => false,
          'enable_secure_admin' => false,
          'manage_java'         => false,
          'parent_dir'          => '/opt',
          'install_dir'         => 'payara',
          'version'             => '4.1.2.181'
          )
        }

        it { is_expected.to contain_class('profiles::glassfish::asadmin_passfile').with(
          'password'        => 'adminadmin',
          'master_password' => 'changeit'
        ) }

        it { is_expected.to contain_class('glassfish').that_requires('Class[profiles::java]') }
      end

      context "with version => 1.2.3, password => secret and master_password => topsecret" do
        let(:params) { {
          'version'         => '1.2.3',
          'password'        => 'secret',
          'master_password' => 'topsecret'
        } }

        it { is_expected.to contain_class('glassfish').with(
          'install_method'      => 'package',
          'package_prefix'      => 'payara',
          'create_service'      => false,
          'create_passfile'     => false,
          'enable_secure_admin' => false,
          'manage_java'         => false,
          'parent_dir'          => '/opt',
          'install_dir'         => 'payara',
          'version'             => '1.2.3'
          )
        }

        it { is_expected.to contain_class('profiles::glassfish::asadmin_passfile').with(
          'password'        => 'secret',
          'master_password' => 'topsecret'
        ) }
      end
    end
  end
end
