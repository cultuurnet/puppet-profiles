describe 'profiles::uitpas::segmentatie' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge({ 'mysqld_version' => '8.0.33' }) }

      context 'in the production environment' do
        let(:environment) { 'production' }
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with required parameters and settings' do
          let(:params) { {
            'servername'        => 'segmentatie.example.com',
            'config_source'     => 'puppet:///modules/profiles/uitpas/segmentatie/config.yml',
            'database_password' => 'mypassword',
            'settings'          => { 'foo' => 'bar' }
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_exec('wait for uitpas-segmentatie glassfish admin').with(
            'command' => "/usr/bin/timeout 120 /bin/sh -c 'until /opt/payara/glassfish/bin/asadmin --passwordfile /home/glassfish/asadmin.pass --port 4848 list-applications >/dev/null 2>&1; do sleep 2; done'",
            'timeout' => 130
          ) }

          it { is_expected.to contain_exec('wait for uitpas-segmentatie glassfish admin').that_requires('Service[uitpas-segmentatie]') }

          it { is_expected.to contain_exec('wait for uitpas-segmentatie glassfish admin after deployment').with(
            'command' => "/usr/bin/timeout 120 /bin/sh -c 'until /opt/payara/glassfish/bin/asadmin --passwordfile /home/glassfish/asadmin.pass --port 4848 list-applications >/dev/null 2>&1; do sleep 2; done'",
            'timeout' => 130
          ) }

          it { is_expected.to contain_exec('wait for uitpas-segmentatie glassfish admin after deployment').that_requires('Class[profiles::uitpas::segmentatie::deployment]') }

          it { is_expected.to contain_exec('restart uitpas-segmentatie after glassfish configuration change').with(
            'command'     => '/usr/bin/systemctl restart uitpas-segmentatie',
            'refreshonly' => true
          ) }

          it { is_expected.to contain_exec('restart uitpas-segmentatie after glassfish configuration change').that_requires('Exec[wait for uitpas-segmentatie glassfish admin]') }
          it { is_expected.to contain_class('profiles::uitpas::segmentatie::deployment').that_requires('Exec[wait for uitpas-segmentatie glassfish admin]') }
          it { is_expected.to contain_class('profiles::uitpas::segmentatie::deployment').that_requires('Jdbcresource[jdbc/cultuurnet-marketing]') }
          it { is_expected.to contain_class('profiles::uitpas::segmentatie::deployment').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_jdbcconnectionpool('mysql_uitpas_segmentatie_j2eePool').that_requires('Exec[wait for uitpas-segmentatie glassfish admin]') }

          it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_set('server.network-config.protocols.protocol.http-listener-1.http.scheme-mapping').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_set('server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_jvmoption('Clear domain uitpas-segmentatie default truststore').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_jvmoption('Clear domain uitpas-segmentatie default truststore').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_jvmoption('Domain uitpas truststore').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_jvmoption('Domain uitpas timezone').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }

          it { is_expected.to contain_systemproperty('foo').that_requires('Exec[wait for uitpas-segmentatie glassfish admin after deployment]') }
          it { is_expected.to contain_systemproperty('foo').that_notifies('Exec[restart uitpas-segmentatie after glassfish configuration change]') }
        end
      end
    end
  end
end
