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
            'syslogtag'   => 'bar',
            'priority'    => 50,
            'destination' => '/var/log/bar.log'
          ) }

          it { is_expected.to contain_class('profiles::rsyslog') }

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
          )}
        end
      end
    end
  end

  context 'with title => baz' do
    let(:title) { 'baz' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context 'with syslogtag => mytag, priority => 20 and destination => /var/log/mytaggedlog.log' do
          let(:params) { {
            'syslogtag'   => 'mytag',
            'priority'    => 20,
            'destination' => '/var/log/mytaggedlog.log'
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
          )}
        end
      end
    end
  end
end
