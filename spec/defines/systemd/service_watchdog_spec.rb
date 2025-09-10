describe 'profiles::systemd::service_watchdog' do
  context 'with title => foo' do
    let(:title) { 'foo' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__systemd__service_watchdog('foo').with(
            'ensure'          => 'present',
            'service'         => 'foo',
            'timeout_seconds' => 10,
            'healthcheck'     => '/usr/bin/true'
          ) }

          it { is_expected.to contain_file('foo-watchdog').with(
            'ensure' => 'file',
            'path'   => '/usr/local/bin/foo-watchdog',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          ) }

          it { is_expected.to contain_file('foo-watchdog').with_content(/CHECK_INTERVAL_SECONDS=5/) }
          it { is_expected.to contain_file('foo-watchdog').with_content(/\/usr\/bin\/true/) }

          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with(
            'ensure' => 'file'
          ) }

          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/Description=Watchdog service for foo/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/Type=notify/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/ExecStart=\/usr\/local\/bin\/foo-watchdog/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/WatchdogSec=10/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/Restart=always/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/NotifyAccess=all/) }

          it { is_expected.to contain_service('foo-watchdog').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_systemd__dropin_file('foo_override.conf').with(
            'ensure'         => 'present',
            'unit'           => 'foo.service',
            'filename'       => 'override.conf',
            'notify_service' => false,
            'content'        => "[Unit]\nRequires=foo-watchdog.service\nAfter=network.target foo-watchdog.service"
          ) }

          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').that_notifies('Service[foo-watchdog]') }
          it { is_expected.to contain_systemd__dropin_file('foo_override.conf').that_requires('Service[foo-watchdog]') }
          it { is_expected.to contain_service('foo-watchdog').that_subscribes_to('File[foo-watchdog]') }
        end

        context 'with service => bar, timeout_seconds => 15 and healthcheck => test -f /tmp/watchdog_file_present' do
          let(:params) { {
            'service'         => 'bar',
            'timeout_seconds' => 15,
            'healthcheck'     => 'test -f /tmp/watchdog_file_present'
          } }

          it { is_expected.to contain_file('foo-watchdog').with_content(/CHECK_INTERVAL_SECONDS=7/) }
          it { is_expected.to contain_file('foo-watchdog').with_content(/test -f \/tmp\/watchdog_file_present/) }

          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/Description=Watchdog service for bar/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/ExecStart=\/usr\/local\/bin\/foo-watchdog/) }
          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with_content(/WatchdogSec=15/) }

          it { is_expected.to contain_systemd__dropin_file('foo_override.conf').with(
            'ensure'         => 'present',
            'unit'           => 'bar.service',
            'filename'       => 'override.conf',
            'notify_service' => false,
            'content'        => "[Unit]\nRequires=foo-watchdog.service\nAfter=network.target foo-watchdog.service"
          ) }
        end

        context 'with ensure => absent' do
          let(:params) { {
            'ensure' => 'absent'
          } }

          it { is_expected.to contain_file('foo-watchdog').with(
            'ensure' => 'absent',
            'path'   => '/usr/local/bin/foo-watchdog'
          ) }

          it { is_expected.to contain_systemd__unit_file('foo-watchdog.service').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.to contain_service('foo-watchdog').with(
            'ensure'    => 'stopped',
            'enable'    => false
          ) }

          it { is_expected.to contain_systemd__dropin_file('foo_override.conf').with(
            'ensure'         => 'absent',
            'unit'           => 'foo.service',
            'filename'       => 'override.conf',
            'notify_service' => false
          ) }
        end
      end
    end
  end

  context 'with title => baz' do
    let(:title) { 'baz' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with healthcheck => "test -f /tmp/baz\ntest -f /tmp/snafu"' do
          let(:params) { {
            'healthcheck' => "test -f /tmp/baz\ntest -f /tmp/snafu"
          } }

          it { is_expected.to contain_file('baz-watchdog').with_content(/test -f \/tmp\/baz/) }
          it { is_expected.to contain_file('baz-watchdog').with_content(/test -f \/tmp\/snafu/) }
        end
      end
    end
  end
end
