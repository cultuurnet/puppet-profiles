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
          'experimental'   => false,
          'schedule_prune' => false
        ) }

        it { is_expected.to contain_class('docker').with(
          'use_upstream_package_source' => false,
          'extra_parameters'            => [ '--experimental=false'],
          'docker_users'                => []
        ) }

        it { is_expected.to_not contain_package('qemu-user-static') }

        it { is_expected.to contain_apt__source('docker').that_comes_before('Class[docker]') }

        it { is_expected.to contain_cron('docker system prune').with(
          'ensure' => 'absent'
        ) }
      end

      context "with experimental => true and schedule_prune => true" do
        let(:params) { {
          'experimental'   => true,
          'schedule_prune' => true
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('docker').with(
          'use_upstream_package_source' => false,
          'extra_parameters'            => [ '--experimental=true'],
          'docker_users'                => []
        ) }

        it { is_expected.to contain_package('qemu-user-static') }

        it { is_expected.to contain_cron('docker system prune').with(
          'ensure'      => 'present',
          'command'     => '/usr/bin/docker system prune -f -a --volumes',
          'environment' => ['MAILTO=infra+cron@publiq.be'],
          'hour'        => '3',
          'minute'      => '30',
          'weekday'     => '0',
        ) }

        it { is_expected.to contain_cron('docker system prune').that_requires('Class[docker]') }
      end
    end
  end
end
