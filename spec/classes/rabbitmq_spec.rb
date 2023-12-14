describe 'profiles::rabbitmq' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with admin_user => 'foo' and admin_password => 'bar'" do
        let(:params) { {
          'admin_user'     => 'foo',
          'admin_password' => 'bar'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::rabbitmq').with(
          'admin_user'     => 'foo',
          'admin_password' => 'bar',
          'erlang_version' => 'latest',
          'version'        => 'latest'
        ) }

        it { is_expected.to contain_package('erlang-nox').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_class('rabbitmq').with(
          'manage_repos'      => false,
          'package_ensure'    => 'latest',
          'delete_guest_user' => true
        ) }

        it { is_expected.to contain_rabbitmq_user('foo').with(
          'admin'    => true,
          'password' => 'bar'
        ) }

        it { is_expected.to contain_package('amqp-tools').with(
          'ensure' => 'present',
        ) }

        it { is_expected.to contain_package('erlang-nox').that_comes_before('Class[rabbitmq]') }
        it { is_expected.to contain_class('rabbitmq').that_comes_before('Rabbitmq_user[foo]') }

        context "with with_tools => false, erlang_version => 1.2.3 and version => 4.5.6" do
          let(:params) {
            super().merge( {
              'with_tools'     => false,
              'erlang_version' => '1.2.3',
              'version'        => '4.5.6'
            } )
          }

          it { is_expected.to contain_package('erlang-nox').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_class('rabbitmq').with(
            'manage_repos'      => false,
            'package_ensure'    => '4.5.6',
            'delete_guest_user' => true
          ) }

          it { is_expected.not_to contain_package('amqp-tools') }
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_user'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
      end
    end
  end
end
