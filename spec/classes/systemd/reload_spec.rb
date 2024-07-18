describe 'profiles::systemd::reload' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_exec('systemd daemon reload').with(
        'command'     => '/usr/bin/systemctl daemon-reload',
        'cwd'         => '/',
        'logoutput'   => true,
        'refreshonly' => true
      ) }
    end
  end
end
