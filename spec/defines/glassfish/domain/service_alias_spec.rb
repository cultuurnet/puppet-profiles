describe 'profiles::glassfish::domain::service_alias' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar" do
        let(:title) { 'foobar' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_systemd__dropin_file('glassfish domain service alias foobar').with(
          'unit'           => 'glassfish-foobar.service',
          'filename'       => 'foobar.conf',
          'notify_service' => false,
          'daemon_reload'  => false,
        ) }

        it { is_expected.to contain_systemd__dropin_file('glassfish domain service alias foobar').with_content(/^\[Install\]\nAlias=foobar.service$/) }

        it { is_expected.to contain_exec('re-enable glassfish domain (foobar)').with(
          'command'     => "systemctl reenable glassfish-foobar",
          'path'        => ['/usr/sbin', '/usr/bin'],
          'refreshonly' => true,
          'logoutput'   => 'on_failure'
        ) }

        it { is_expected.to contain_systemd__dropin_file('glassfish domain service alias foobar').that_requires('Class[profiles::glassfish]') }
        it { is_expected.to contain_exec('re-enable glassfish domain (foobar)').that_subscribes_to('Systemd::Dropin_file[glassfish domain service alias foobar]') }
      end

      context "title baz" do
        let(:title) { 'baz' }

        it { is_expected.to contain_systemd__dropin_file('glassfish domain service alias baz').with(
          'unit'           => 'glassfish-baz.service',
          'filename'       => 'baz.conf',
          'notify_service' => false,
          'daemon_reload'  => false,
        ) }

        it { is_expected.to contain_systemd__dropin_file('glassfish domain service alias baz').with_content(/^\[Install\]\nAlias=baz.service$/) }

        it { is_expected.to contain_exec('re-enable glassfish domain (baz)').with(
          'command'     => "systemctl reenable glassfish-baz",
          'path'        => ['/usr/sbin', '/usr/bin'],
          'refreshonly' => true,
          'logoutput'   => 'on_failure'
        ) }

      end
    end
  end
end
