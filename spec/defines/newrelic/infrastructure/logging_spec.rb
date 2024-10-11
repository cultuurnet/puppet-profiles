describe 'profiles::newrelic::infrastructure::logging' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with title => mysql-error-log' do
          let(:title) { 'mysql-error-log' }

          context 'with source => /var/log/mysql/error.log' do
            let(:params) { {
              'source' => '/var/log/mysql/error.log'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::newrelic::infrastructure') }

            it { is_expected.to contain_profiles__newrelic__infrastructure__logging('mysql-error-log').with(
              'source_type' => 'file',
              'source'      => '/var/log/mysql/error.log',
              'pattern'     => nil,
              'attributes'  => {}
            ) }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-error-log').with(
              'ensure' => 'file',
              'path'   => '/etc/newrelic-infra/logging.d/mysql-error-log.yml'
            ) }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-error-log').with_content(/^logs:\n\s{2}- name: mysql-error-log\n\s{4}file: \/var\/log\/mysql\/error.log$/) }

            it { is_expected.not_to contain_file('newrelic-infrastructure-mysql-error-log').with_content(/^\s{4}pattern:$/) }
            it { is_expected.not_to contain_file('newrelic-infrastructure-mysql-error-log').with_content(/^\s{4}attributes:$/) }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-error-log').that_requires('Class[profiles::newrelic::infrastructure::install]') }
            it { is_expected.to contain_file('newrelic-infrastructure-mysql-error-log').that_notifies('Class[profiles::newrelic::infrastructure::service]') }
          end
        end

        context 'with title => mysql-slow-query-log' do
          let(:title) { 'mysql-slow-query-log' }

          context 'with source => /var/log/mysql/slow-query.log, pattern => WARN|ERROR and attributes => { logtype => mysql-slow-query-log, attribute1 => value }' do
            let(:params) { {
              'source'     => '/var/log/mysql/slow-query.log',
              'pattern'    => 'WARN|ERROR',
              'attributes' => { 'logtype' => 'mysql-slow-query-log', 'attribute1' => 'value' }
            } }

            it { is_expected.to contain_class('profiles::newrelic::infrastructure') }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-slow-query-log').with(
              'ensure'  => 'file',
              'path'    => '/etc/newrelic-infra/logging.d/mysql-slow-query-log.yml'
            ) }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-slow-query-log').with_content(/^logs:\n\s{2}- name: mysql-slow-query-log\n\s{4}file: \/var\/log\/mysql\/slow-query.log\n\s{4}pattern: WARN\|ERROR$/) }
            it { is_expected.to contain_file('newrelic-infrastructure-mysql-slow-query-log').with_content(/^\s{4}attributes:\n\s{6}logtype: mysql-slow-query-log\n\s{6}attribute1: value$/) }

            it { is_expected.to contain_file('newrelic-infrastructure-mysql-slow-query-log').that_requires('Class[profiles::newrelic::infrastructure::install]') }
            it { is_expected.to contain_file('newrelic-infrastructure-mysql-slow-query-log').that_notifies('Class[profiles::newrelic::infrastructure::service]') }
          end

          context 'without parameters' do
            let(:params) { {} }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'source'/) }
          end
        end

        context 'with title => systemd-cupsd' do
          let(:title) { 'systemd-cupsd' }

          context 'with source_type => systemd and source => cupsd' do
            let(:params) { {
              'source_type' => 'systemd',
              'source'      => 'cupsd'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('newrelic-infrastructure-systemd-cupsd').with_content(/^logs:\n\s{2}- name: systemd-cupsd\n\s{4}systemd: cupsd$/) }
          end
        end

        context 'with title => syslog-tcp-test' do
          let(:title) { 'syslog-tcp-test' }

          context 'with source_type => tcp and source => { uri => tcp://0.0.0.0:5140, parser => rfc5424 }' do
            let(:params) { {
              'source_type' => 'tcp',
              'source'      => {
                                 'uri'    => 'tcp://0.0.0.0:5140',
                                 'parser' => 'rfc5424'
                               }
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('newrelic-infrastructure-syslog-tcp-test').with_content(/^logs:\n\s{2}- name: syslog-tcp-test\n\s{4}tcp:\n\s{6}uri: tcp:\/\/0\.0\.0\.0:5140\n\s{6}parser: rfc5424$/) }
          end
        end
      end
    end
  end
end
