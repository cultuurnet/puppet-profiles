describe 'profiles::apache::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::logrotate') }
        it { is_expected.to contain_class('profiles::apache::logging').with( 

          'keep_logs_days' => 21,
        ) }

        it { is_expected.to contain_logrotate__rule('apache2').with(
          'path'          => '/var/log/apache2/*.log',
          'rotate'        => 21,
          'rotate_every'  => 'day',
          'create'        => true,
          'create_mode'   => '0640',
          'create_owner'  => 'root',
          'create_group'  => 'adm',
          'compress'      => true,
          'delaycompress' => true,
          'sharedscripts' => true,
          'postrotate'    => 'systemctl status apache2 > /dev/null 2>&1 && systemctl reload apache2 > /dev/null 2>&1'
        ) }
      end
      context 'with keep_logs_days => 30' do
        let(:params) { {
          'keep_logs_days' => 30
        } }

        it { is_expected.to contain_logrotate__rule('apache2').with(
          'path'          => '/var/log/apache2/*.log',
          'rotate'        => 30,
          'rotate_every'  => 'day',
          'create'        => true,
          'create_mode'   => '0640',
          'create_owner'  => 'root',
          'create_group'  => 'adm',
          'compress'      => true,
          'delaycompress' => true,
          'sharedscripts' => true,
          'postrotate'    => 'systemctl status apache2 > /dev/null 2>&1 && systemctl reload apache2 > /dev/null 2>&1'
        ) }
      end
    end
  end
end
