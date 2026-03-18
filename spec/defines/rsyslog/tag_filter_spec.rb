describe 'profiles::rsyslog::tag_filter' do
  context 'with title => foo' do
    let(:title) { 'foo' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with syslogtag => bar and destination => /var/log/bar.log' do
          let(:params) { {
            'syslogtag'   => 'bar',
            'destination' => '/var/log/bar.log'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__rsyslog__tag_filter('foo').with(
            'syslogtag'      => 'bar',
            'priority'       => 50,
            'destination'    => '/var/log/bar.log',
            'retention_days' => 7
          ) }

          it { is_expected.to contain_class('profiles::rsyslog') }
          it { is_expected.to contain_class('profiles::logrotate') }

          it { is_expected.to contain_rsyslog__component__expression_filter('foo').with(
            'priority'     => 0,
            'confdir'      => '/etc/rsyslog.d',
            'target'       => '50_foo.conf',
            'conditionals' => {
                                'main' => {
                                  'expression' => '$syslogtag contains "bar"',
                                  'tasks'      => [
                                                    {
                                                      'action' => {
                                                        'type'   => 'omfile',
                                                        'config' => { 'file' => '/var/log/bar.log' }
                                                      }
                                                    },
                                                    { 'stop' => true }
                                                  ]
                                }
                              }
          ) }

          it { is_expected.to contain_logrotate__rule('foo').with(
            'path'          => '/var/log/bar.log',
            'rotate'        => 6,
            'rotate_every'  => 'day',
            'create'        => true,
            'create_mode'   => '0640',
            'create_owner'  => 'root',
            'create_group'  => 'adm',
            'compress'      => true,
            'delaycompress' => true,
            'sharedscripts' => true,
            'postrotate'    => '/usr/lib/rsyslog/rsyslog-rotate'
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

        context 'with syslogtag => mytag, priority => 20, destination => /var/log/mytaggedlog.log and retention_days => 21' do
          let(:params) { {
            'syslogtag'      => 'mytag',
            'priority'       => 20,
            'destination'    => '/var/log/mytaggedlog.log',
            'retention_days' => 21
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_rsyslog__component__expression_filter('baz').with(
            'priority'     => 0,
            'confdir'      => '/etc/rsyslog.d',
            'target'       => '20_baz.conf',
            'conditionals' => {
                                'main' => {
                                  'expression' => '$syslogtag contains "mytag"',
                                  'tasks'      => [
                                                    {
                                                      'action' => {
                                                        'type'   => 'omfile',
                                                        'config' => { 'file' => '/var/log/mytaggedlog.log' }
                                                      }
                                                    },
                                                    { 'stop' => true }
                                                  ]
                                }
                              }
          ) }

          it { is_expected.to contain_logrotate__rule('baz').with(
            'path'          => '/var/log/mytaggedlog.log',
            'rotate'        => 20,
            'rotate_every'  => 'day',
            'create'        => true,
            'create_mode'   => '0640',
            'create_owner'  => 'root',
            'create_group'  => 'adm',
            'compress'      => true,
            'delaycompress' => true,
            'sharedscripts' => true,
            'postrotate'    => '/usr/lib/rsyslog/rsyslog-rotate'
          ) }
        end
      end
    end
  end
end
