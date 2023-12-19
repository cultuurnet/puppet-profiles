describe 'profiles::php::fpm_service_alias' do
  context "with title => my_service" do
    let(:title) { 'my_service' }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_profiles__php__fpm_service_alias('my_service') }

          it { is_expected.to contain_systemd__dropin_file('php-fpm service alias my_service').with(
            'unit'           => 'php7.4-fpm.service',
            'filename'       => 'my_service.conf',
            'content'        => "[Install]\nAlias=my_service.service",
            'notify_service' => false,
            'daemon_reload'  => false
          ) }

          it { is_expected.to contain_exec('re-enable php7.4-fpm (my_service)').with(
            'command'     => 'systemctl reenable php7.4-fpm',
            'path'        => ['/usr/sbin', '/usr/bin'],
            'refreshonly' => true,
            'logoutput'   => 'on_failure'
          ) }

          it { is_expected.to contain_exec('re-enable php7.4-fpm (my_service)').that_subscribes_to('Systemd::Dropin_file[php-fpm service alias my_service]') }
          it { is_expected.to contain_systemd__dropin_file('php-fpm service alias my_service').that_requires('Class[profiles::php]') }
        end
      end
    end
  end

  context "with title => foo_service" do
    let(:title) { 'foo_service' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with PHP 8.2 installed" do
          let(:pre_condition) { 'class { profiles::php: version => "8.2" }' }

          it { is_expected.to contain_systemd__dropin_file('php-fpm service alias foo_service').with(
            'unit'           => 'php8.2-fpm.service',
            'filename'       => 'foo_service.conf',
            'content'        => "[Install]\nAlias=foo_service.service",
            'notify_service' => false,
            'daemon_reload'  => false
          ) }

          it { is_expected.to contain_exec('re-enable php8.2-fpm (foo_service)').with(
            'command'     => 'systemctl reenable php8.2-fpm',
            'path'        => ['/usr/sbin', '/usr/bin'],
            'refreshonly' => true,
            'logoutput'   => 'on_failure'
          ) }

          it { is_expected.to contain_exec('re-enable php8.2-fpm (foo_service)').that_subscribes_to('Systemd::Dropin_file[php-fpm service alias foo_service]') }
          it { is_expected.to contain_systemd__dropin_file('php-fpm service alias foo_service').that_requires('Class[profiles::php]') }
        end
      end
    end
  end
end
