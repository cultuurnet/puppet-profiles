describe 'profiles::uitpas::api::cron' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitpas::api::cron').with(
          'portbase' => 4800
        ) }

        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_cron('uitpas enduser clearcheckincodes').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/enduser/clearcheckincodes' >> /var/log/uitpas-cron/clearcheckincodes.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '3',
          'minute'      => '5'
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch activity').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/activity' >> /var/log/uitpas-cron/activity.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '1',
          'minute'      => '2'
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch points').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/points' >> /var/log/uitpas-cron/points.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '2',
          'minute'      => '2'
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch birthday').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/milestone/batch/birthday' >> /var/log/uitpas-cron/birthday.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '4',
          'minute'      => '2'
        ) }

        it { is_expected.to contain_cron('uitpas passholder indexpointspromotions').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> /var/log/uitpas-cron/indexpointspromotions.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '34'
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerupload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerupload' >> /var/log/uitpas-cron/triggerupload.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10'
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerdownload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerdownload' >> /var/log/uitpas-cron/triggerdownload.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10'
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerprocess').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/autorenew/triggerprocess' >> /var/log/uitpas-cron/triggerprocess.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '*',
          'minute'      => '*/10'
        ) }

        it { is_expected.to contain_cron('uitpas balie indexbalies').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:4880/uitid/rest/uitpas/balie/indexbalies' >> /var/log/uitpas-cron/indexbalies.log 2>&1",
          'user'        => 'glassfish',
          'hour'        => '5',
          'minute'      => '14'
        ) }

        it { is_expected.to contain_cron('uitpas clear jpa cache').with(
          'command'     => "/usr/bin/curl -q -s 'http://127.0.0.1:4880/uitid/rest/bootstrap/uitpas/clearJpaCache' > /dev/null",
          'user'        => 'glassfish',
          'hour'        => '*/6',
          'minute'      => '30'
        ) }

        it { is_expected.to contain_cron('uitpas clear cache').with(
          'command'     => "/usr/bin/curl -q -s 'http://127.0.0.1:4880/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
          'user'        => 'glassfish',
          'hour'        => '6',
          'minute'      => '15'
        ) }

        it { is_expected.to contain_cron('uitpas enduser clearcheckincodes').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas milestone batch activity').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas milestone batch points').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas milestone batch birthday').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas passholder indexpointspromotions').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas autorenew triggerupload').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas autorenew triggerdownload').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas autorenew triggerprocess').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas balie indexbalies').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas clear jpa cache').that_requires('User[glassfish]') }
        it { is_expected.to contain_cron('uitpas clear cache').that_requires('User[glassfish]') }
      end

      context "with portbase => 14800" do
        let(:params) { {
          'portbase' => 14800
        } }

        it { is_expected.to contain_cron('uitpas enduser clearcheckincodes').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/enduser/clearcheckincodes' >> /var/log/uitpas-cron/clearcheckincodes.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch activity').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/milestone/batch/activity' >> /var/log/uitpas-cron/activity.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch points').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/milestone/batch/points' >> /var/log/uitpas-cron/points.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas milestone batch birthday').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/milestone/batch/birthday' >> /var/log/uitpas-cron/birthday.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas passholder indexpointspromotions').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/passholder/indexpointspromotions?unindexedOnly=true' >> /var/log/uitpas-cron/indexpointspromotions.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerupload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/autorenew/triggerupload' >> /var/log/uitpas-cron/triggerupload.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerdownload').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/autorenew/triggerdownload' >> /var/log/uitpas-cron/triggerdownload.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas autorenew triggerprocess').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/autorenew/triggerprocess' >> /var/log/uitpas-cron/triggerprocess.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas balie indexbalies').with(
          'command'     => "/usr/bin/curl 'http://127.0.0.1:14880/uitid/rest/uitpas/balie/indexbalies' >> /var/log/uitpas-cron/indexbalies.log 2>&1",
        ) }

        it { is_expected.to contain_cron('uitpas clear jpa cache').with(
          'command'     => "/usr/bin/curl -q -s 'http://127.0.0.1:14880/uitid/rest/bootstrap/uitpas/clearJpaCache' > /dev/null",
        ) }

        it { is_expected.to contain_cron('uitpas clear cache').with(
          'command'     => "/usr/bin/curl -q -s 'http://127.0.0.1:14880/uitid/rest/bootstrap/uitpas/clearcaches' > /dev/null",
        ) }
      end
    end
  end
end
