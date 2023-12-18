describe 'profiles::uitdatabank::entry_api::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_group('www-data') }
      it { is_expected.to contain_user('www-data') }

      it { is_expected.to contain_class('profiles::logrotate') }

      it { is_expected.to contain_logrotate__rule('uitdatabank-entry-api').with(
        'path'          => '/var/www/udb3-backend/log/*.log',
        'rotate'        => 10,
        'create_owner'  => 'www-data',
        'create_group'  => 'www-data',
        'postrotate'    => 'systemctl restart udb3-amqp-listener-uitpas udb3-bulk-label-offer-worker udb3-event-export-workers.target',
        'rotate_every'  => 'day',
        'missingok'     => true,
        'create'        => true,
        'ifempty'       => true,
        'create_mode'   => '0640',
        'compress'      => true,
        'delaycompress' => true,
        'sharedscripts' => true
      ) }

      it { is_expected.to contain_logrotate__rule('uitdatabank-entry-api').that_requires('Group[www-data]') }
      it { is_expected.to contain_logrotate__rule('uitdatabank-entry-api').that_requires('User[www-data]') }
    end
  end
end
