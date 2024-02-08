describe 'profiles::uit::notifications' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with database_password => p4ssw0rd' do
        let(:params) { {
          'database_password' => 'p4ssw0rd'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uit::notifications').with(
            'database_password' => 'p4ssw0rd',
            'deployment'        => true
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_class('profiles::nodejs') }
          it { is_expected.to contain_class('profiles::uit::notifications::deployment') }

          it { is_expected.to contain_class('profiles::uit::notifications::deployment').that_requires('Group[www-data]') }
          it { is_expected.to contain_class('profiles::uit::notifications::deployment').that_requires('User[www-data]') }
          it { is_expected.to contain_class('profiles::uit::notifications::deployment').that_requires('Class[profiles::nodejs]') }

          context 'in the acceptance environment' do
            let(:environment) { 'acceptance' }

            it { expect(exported_resources).to contain_profiles__mysql__app_user('uit_notifications').with(
              'database' => 'uit_api',
              'password' => 'p4ssw0rd',
              'remote'   => true,
              'tag'      => 'acceptance'
            ) }
          end

          context 'in the testing environment' do
            let(:environment) { 'testing' }

            it { expect(exported_resources).to contain_profiles__mysql__app_user('uit_notifications').with(
              'database' => 'uit_api',
              'password' => 'p4ssw0rd',
              'remote'   => true,
              'tag'      => 'testing'
            ) }
          end

          context 'with deployment => false' do
            let(:params) {
              super().merge({ 'deployment' => false })
            }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to_not contain_class('profiles::uit::notifications::deployment') }
          end
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        end
      end

      context 'with database_password => foo' do
        let(:params) { {
          'database_password' => 'foo'
        } }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          context 'in the production environment' do
            let(:environment) { 'production' }

            it { expect(exported_resources).to contain_profiles__mysql__app_user('uit_notifications').with(
              'database' => 'uit_api',
              'password' => 'foo',
              'remote'   => true,
              'tag'      => 'production'
            ) }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_password'/) }
      end
    end
  end
end
