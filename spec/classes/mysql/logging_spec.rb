describe 'profiles::mysql::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::logrotate') }
      it { is_expected.to contain_user('mysql') }

      it { is_expected.to contain_logrotate__rule('mysql-server').with(
        'ensure' => 'absent'
      ) }

      it { is_expected.to contain_logrotate__rule('mysql-server-slow-query').with(
        'path'          => '/var/log/mysql/slow-query.log',
        'rotate'        => 30,
        'rotate_every'  => 'day',
        'create'        => true,
        'create_mode'   => '0640',
        'create_owner'  => 'mysql',
        'create_group'  => 'adm',
        'compress'      => true,
        'delaycompress' => true,
        'sharedscripts' => true,
        'copytruncate'  => false,
        'postrotate'    => '/usr/bin/mysql -e "select @@global.slow_query_log into @sq_log_save; set global slow_query_log=off; select sleep(5); FLUSH SLOW LOGS; select sleep(10); set global slow_query_log=@sq_log_save;"'
      ) }

      it { is_expected.to contain_logrotate__rule('mysql-server-error').with(
        'path'          => '/var/log/mysql/error.log',
        'rotate'        => 30,
        'rotate_every'  => 'day',
        'create'        => true,
        'create_mode'   => '0640',
        'create_owner'  => 'mysql',
        'create_group'  => 'adm',
        'compress'      => true,
        'delaycompress' => true,
        'sharedscripts' => true,
        'copytruncate'  => false,
        'postrotate'    => '/usr/bin/mysqladmin --defaults-file="/root/.my.cnf" flush-logs error'
      ) }

      it { is_expected.to contain_logrotate__rule('mysql-server-slow-query').that_requires('User[mysql]') }
      it { is_expected.to contain_logrotate__rule('mysql-server-error').that_requires('User[mysql]') }
    end
  end
end
