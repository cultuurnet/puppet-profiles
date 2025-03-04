describe 'profiles::glassfish::domain::service_alias' do
  context "with title => my_service" do
    let(:title) { 'my_service' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file('my_service glassfish domain service alias link').with(
          'ensure'  => 'link',
          'path'    => '/etc/systemd/system/my_service.service',
          'target'  => '/lib/systemd/system/glassfish-my_service.service'
        ) }

        it { is_expected.to contain_systemd__daemon_reload('my_service') }

        it { is_expected.to contain_file('my_service glassfish domain service alias link').that_requires('Class[profiles::glassfish]') }
        it { is_expected.to contain_file('my_service glassfish domain service alias link').that_notifies('Systemd::Daemon_reload[my_service]') }
      end
    end
  end

  context "with title => foo_service" do
    let(:title) { 'foo_service' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_file('foo_service glassfish domain service alias link').with(
          'ensure'  => 'link',
          'path'    => '/etc/systemd/system/foo_service.service',
          'target'  => '/lib/systemd/system/glassfish-foo_service.service'
        ) }

        it { is_expected.to contain_systemd__daemon_reload('foo_service') }

        it { is_expected.to contain_file('foo_service glassfish domain service alias link').that_requires('Class[profiles::glassfish]') }
        it { is_expected.to contain_file('foo_service glassfish domain service alias link').that_notifies('Systemd::Daemon_reload[foo_service]') }
      end
    end
  end
end
