describe 'profiles::newrelic::infrastructure::integration' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with title => mysql' do
          let(:title) { 'mysql' }

          context 'in the testing environment' do
            let(:environment) { 'testing' }

            context 'without parameters' do
              let(:params) { {} }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('profiles::newrelic::infrastructure') }

              it { is_expected.to contain_profiles__newrelic__infrastructure__integration('mysql').with(
                'check_interval' => '30s',
                'labels'         => {},
                'conditions'     => {},
                'configuration'  => {}
              ) }

              it { is_expected.to contain_apt__source('newrelic-infra') }
              it { is_expected.to contain_package('nri-mysql').with(
                'ensure' => 'latest'
              ) }

              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with(
                'ensure' => 'file',
                'path'   => '/etc/newrelic-infra/integrations.d/mysql-config.yml'
              ) }

              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with_content(/^- name: nri-mysql$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{2}interval: 30s$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{2}timeout: 5s$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{2}inventory_source: integrations\/mysql$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{4}environment: testing$/) }

              it { is_expected.not_to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{2}when:$/) }
              it { is_expected.not_to contain_file('newrelic-infrastructure-mysql-config').with_content(/^\s{2}env:$/) }

              it { is_expected.to contain_apt__source('newrelic-infra').that_comes_before('Package[nri-mysql]') }
              it { is_expected.to contain_package('nri-mysql').that_comes_before('File[newrelic-infrastructure-mysql-config]') }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').that_requires('Class[profiles::newrelic::infrastructure::install]') }
              it { is_expected.to contain_file('newrelic-infrastructure-mysql-config').that_notifies('Class[profiles::newrelic::infrastructure::service]') }
            end
          end
        end

        context 'with title => nri-redis' do
          let(:title) { 'nri-redis' }

          context 'in the production environment' do
            let(:environment) { 'production' }

            context 'with check_interval => 15s, labels => { first => 1, second => 2 }, conditions => { feature => bla, file_exists => /tmp/bla } and configuration => { DATABASE => postgres, VERBOSE => 1 }' do
              let(:params) { {
                'check_interval' => '15s',
                'labels'         => { 'first' => 1, 'second' => 2 },
                'conditions'     => { 'feature' => 'bla', 'file_exists' => '/tmp/bla' },
                'configuration'  => { 'DATABASE' => 'postgres', 'VERBOSE' => 1 }
              } }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('profiles::newrelic::infrastructure') }

              it { is_expected.to contain_apt__source('newrelic-infra') }
              it { is_expected.to contain_package('nri-redis').with(
                'ensure' => 'latest'
              ) }

              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with(
                'ensure' => 'file',
                'path'   => '/etc/newrelic-infra/integrations.d/redis-config.yml'
              ) }

              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^- name: nri-redis$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}interval: 15s$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}timeout: 5s$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}inventory_source: integrations\/redis$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}labels:\n\s{4}environment: production\n\s{4}first: 1\n\s{4}second: 2$/) }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}when:\n\s{4}feature: bla\n\s{4}file_exists: \/tmp\/bla$/) }

              it { is_expected.to contain_apt__source('newrelic-infra').that_comes_before('Package[nri-redis]') }
              it { is_expected.to contain_package('nri-redis').that_comes_before('File[newrelic-infrastructure-redis-config]') }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').that_requires('Class[profiles::newrelic::infrastructure::install]') }
              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').that_notifies('Class[profiles::newrelic::infrastructure::service]') }
            end

            context 'with conditions => { feature => foo, env_exists => { VAR1 => VAL1, VAR2 => VAL2 } }' do
              let(:params) { {
                'conditions' => { 'feature' => 'foo', 'env_exists' => { 'VAR1' => 'VAL1', 'VAR2' => 'VAL2' } }
              } }

              it { is_expected.to contain_file('newrelic-infrastructure-redis-config').with_content(/^\s{2}when:\n\s{4}feature: foo\n\s{4}env_exists:\n\s{6}VAR1: VAL1\n\s{6}VAR2: VAL2$/) }
            end
          end
        end
      end
    end
  end
end
