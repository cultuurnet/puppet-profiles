describe 'profiles::puppet::puppetserver::install' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::install').with(
          'version' => 'installed'
        ) }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_apt__source('puppet') }
        it { is_expected.to contain_apt__source('openvox') }

        it { is_expected.to contain_class('profiles::java') }
        it { is_expected.to contain_package('openvox-server').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_package('openvox-server').that_requires('Group[puppet]') }
        it { is_expected.to contain_package('openvox-server').that_requires('User[puppet]') }
        it { is_expected.to contain_package('openvox-server').that_requires('Apt::Source[openvox]') }
        it { is_expected.to contain_package('openvox-server').that_requires('Class[profiles::java]') }
      end

      context "with version => 1.2.3" do
        let(:params) { {
          'version' => '1.2.3'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openvox-server').with(
          'ensure' => '1.2.3'
        ) }
      end
    end
  end
end
