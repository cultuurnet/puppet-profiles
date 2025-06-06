
describe 'profiles::systemd' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
     let(:facts) { facts }


    context 'with default parameters' do
        it { is_expected.to compile }

        it {
            is_expected.to contain_class('systemd')
        }

        it {
            is_expected.to contain_systemd__journald('SystemMaxUse').with(
                'settings' => {
                    'Journal' => {
                        'SystemMaxUse' => '500M',
                    },
                },
                'notify' => 'Exec[systemd-journald-reload]',
            )
        }

        it {
            is_expected.to contain_exec('systemd-journald-reload').with(
                'command'     => '/bin/systemctl reload systemd-journald',
                'refreshonly' => true,
                'path'        => ['/bin', '/usr/bin'],
            )
        }
    end

    context 'with custom system_max_use' do
        let(:params) { { system_max_use: '1G' } }

        it {
            is_expected.to contain_systemd__journald('SystemMaxUse').with(
                'settings' => {
                    'Journal' => {
                        'SystemMaxUse' => '1G',
                    },
                }
            )
        }
    end
end