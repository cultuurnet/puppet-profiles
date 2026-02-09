describe 'profiles::uitpas::api::cron' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api::cron').with(
          'portbase' => 4800,
          'cron_enabled' => true,
          'local_timezone' => 'Europe/Brussels',
        ) }

        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }
        it { is_expected.to contain_file('/var/log/uitpas-cron') }

        it { is_expected.to contain_cron('uitpas enduser clearcheckincodes').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 3 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/enduser/clearcheckincodes' >> /var/log/uitpas-cron/clearcheckincodes.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '5',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch activity').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 1 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/activity' >> /var/log/uitpas-cron/activity.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '2',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch points').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 2 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/points' >> /var/log/uitpas-cron/points.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '2',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch birthday').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 4 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/birthday' >> /var/log/uitpas-cron/birthday.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '2',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas passholder indexpointspromotions').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> /var/log/uitpas-cron/indexpointspromotions.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '34',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerupload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerupload' >> /var/log/uitpas-cron/triggerupload.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerdownload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerdownload' >> /var/log/uitpas-cron/triggerdownload.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerprocess').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerprocess' >> /var/log/uitpas-cron/triggerprocess.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas trigger price message').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/bootstrap/uitpas/trigger-event-price-messages?max=100' >> /var/log/uitpas-cron/trigger-event-price-message.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas balie indexbalies').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 5 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/balie/indexbalies' >> /var/log/uitpas-cron/indexbalies.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '14',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas clear jpa cache').with(
          'command'     => "/usr/bin/curl -q -s 'http://127.0.0.1:4880/uitid/rest/bootstrap/uitpas/clearJpaCache' > /dev/null",
          'user'        => 'glassfish',
          'hour'        => '*/6',
          'minute'      => '30',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas clear cache').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 6 && /usr/bin/curl -q -s 'http://127.0.0.1:4880/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '15',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas balie financial reminderemail').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 8 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/balie/financial-reminderemail' >> /var/log/uitpas-cron/balie-financial-reminderemail.log 2>&1",
          'hour'        => '*',
          'minute'      => '0',
          'monthday'    => '1',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas balie financial export cleanup').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 1 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/balie/financial-export-cleanup' >> /var/log/uitpas-cron/balie-financial-export-cleanup.log 2>&1",
          'hour'        => '*',
          'minute'      => '14',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas balie checkcardstockunderlimit').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 0 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/balie/checkcardstockunderlimit' >> /var/log/uitpas-cron/balie-checkcardstockunderlimit.log 2>&1",
          'hour'        => '*',
          'minute'      => '15',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas orders trigger order completion').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/orders/trigger-order-completion' >> /var/log/uitpas-cron/orders-trigger-order-completion.log 2>&1",
          'hour'        => '*',
          'minute'      => '*/5',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas orders check incomplete orders').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 9 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/orders/check-incomplete-orders' >> /var/log/uitpas-cron/orders-check-incomplete-orders.log 2>&1",
          'hour'        => '*',
          'minute'      => '0',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas passholder kansenstatuutalmostexpired').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 0 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/passholder/kansenstatuutalmostexpired' >> /var/log/uitpas-cron/passholder-kansenstatuutalmostexpired.log 2>&1",
          'hour'        => '*',
          'minute'      => '45',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas passholder norecentcheckinreminder').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 0 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/passholder/norecentcheckinreminder' >> /var/log/uitpas-cron/passholder-norecentcheckinreminder.log 2>&1",
          'hour'        => '*',
          'minute'      => '25',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas passholder welcomemailreminder').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 0 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/passholder/welcomemailreminder' >> /var/log/uitpas-cron/passholder-welcomemailreminder.log 2>&1",
          'hour'        => '*',
          'minute'      => '10',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas periodic cardsystemmembership cleaning').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 3 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/periodic-cardsystemmembership-cleaning' >> /var/log/uitpas-cron/periodic-cardsystemmembership-cleaning.log 2>&1",
          'hour'        => '*',
          'minute'      => '38',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas external ticketsales sync').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 4 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/external-ticketsales/sync' >> /var/log/uitpas-cron/external-ticketsales-sync.log 2>&1",
          'hour'        => '*',
          'minute'      => '45',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas external ticketsales resolve').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 5 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/external-ticketsales/resolve' >> /var/log/uitpas-cron/external-ticketsales-resolve.log 2>&1",
          'hour'        => '*',
          'minute'      => '1',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas external ticketsales process').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 5 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/external-ticketsales/process' >> /var/log/uitpas-cron/external-ticketsales-process.log 2>&1",
          'hour'        => '*',
          'minute'      => '45',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas external ticketsales alert').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 6 && /usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/cron/external-ticketsales/alert' >> /var/log/uitpas-cron/external-ticketsales-alert.log 2>&1",
          'hour'        => '*',
          'minute'      => '45',
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }
      end

      context "with portbase => 14800 and cron_enabled => true" do
        let(:params) { {
          'portbase' => 14800,
          'cron_enabled' => true
        } }

        it { is_expected.to contain_cron('uitpas enduser clearcheckincodes').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 3 && /usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/enduser/clearcheckincodes' >> /var/log/uitpas-cron/clearcheckincodes.log 2>&1",
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }

        it { is_expected.to contain_cron('uitpas clear cache').with(
          'command'     => "/usr/bin/test $(date +\\%H) -eq 6 && /usr/bin/curl -q -s 'http://127.0.0.1:14880/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Brussels'],
        ) }
      end
    end
  end
end

