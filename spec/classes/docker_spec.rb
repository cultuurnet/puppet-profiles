describe 'profiles::docker' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('docker') }

        it { is_expected.to contain_class('profiles::docker').with(
          'experimental' => false
        ) }

        it { is_expected.to contain_class('docker').with(
          'use_upstream_package_source' => false,
          'extra_parameters'            => [ '--experimental=false'],
          'docker_users'                => []
        ) }

        it { is_expected.to_not contain_package('qemu-user-static') }

        it { is_expected.to contain_apt__source('docker').that_comes_before('Class[docker]') }
      end

      context "with experimental => true" do
        let(:params) { {
          'experimental' => true
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('docker').with(
          'use_upstream_package_source' => false,
          'extra_parameters'            => [ '--experimental=true'],
          'docker_users'                => []
        ) }

        it { is_expected.to contain_package('qemu-user-static') }
      end
    end
  end
end
