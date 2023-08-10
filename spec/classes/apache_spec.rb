require 'spec_helper'

describe 'profiles::apache' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::apache').with(
          'mpm_module'        => 'prefork',
          'mpm_module_config' => {},
          'log_formats'       => {},
          'http2'             => false,
          'service_status'    => 'running',
          'metrics'           => true
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('apache').with(
          'mpm_module'            => false,
          'manage_group'          => false,
          'manage_user'           => false,
          'default_vhost'         => true,
          'protocols'             => ['http/1.1'],
          'protocols_honor_order' => true,
          'service_manage'        => true,
          'service_ensure'        => 'running',
          'service_enable'        => true,
          'log_formats'           => {
                                       'combined_json' => '{ \"client_ip\": \"%a\", \"remote_logname\": \"%l\", \"user\": \"%u\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"request\": \"%r\", \"status\": %>s, \"response_bytes\": %b, \"referer\": \"%{Referer}i\", \"user_agent\": \"%{User-Agent}i\" }'
                                     }
        ) }

        it { is_expected.to contain_class('apache::mod::prefork') }

        it { is_expected.to contain_class('profiles::apache::metrics') }
        it { is_expected.to contain_class('profiles::apache::logging') }

        it { is_expected.to contain_apache__mod('unique_id') }

        it { is_expected.to contain_group('www-data').that_comes_before('Class[apache]') }
        it { is_expected.to contain_user('www-data').that_comes_before('Class[apache]') }
      end

      context "with mpm_module => worker, mpm_module_config => { startservers => 8, maxclients => 256 }, http2 => true, log_formats => { a => '{ client_ip: %a }', b => '{ response_bytes: %b }' }, service_status => stopped and metrics => false" do
        let(:params) { {
          'mpm_module'        => 'worker',
          'mpm_module_config' => { 'startservers' => 8, 'maxclients' => 256 },
          'http2'             => true,
          'log_formats'       => { 'a' => '{ \"client_ip\": \"%a\" }', 'b' => '{ \"response_bytes\": %b }' },
          'service_status'    => 'stopped',
          'metrics'           => false
        } }

        it { is_expected.to contain_class('apache').with(
          'mpm_module'            => false,
          'manage_group'          => false,
          'manage_user'           => false,
          'default_vhost'         => true,
          'protocols'             => ['h2c', 'http/1.1'],
          'protocols_honor_order' => true,
          'service_manage'        => true,
          'service_ensure'        => 'stopped',
          'service_enable'        => false,
          'log_formats'           => {
                                       'combined_json' => '{ \"client_ip\": \"%a\", \"remote_logname\": \"%l\", \"user\": \"%u\", \"time\": \"%{%Y-%m-%d %H:%M:%S}t.%{msec_frac}t\", \"request\": \"%r\", \"status\": %>s, \"response_bytes\": %b, \"referer\": \"%{Referer}i\", \"user_agent\": \"%{User-Agent}i\" }',
                                       'a'             => '{ \"client_ip\": \"%a\" }',
                                       'b'             => '{ \"response_bytes\": %b }'
                                     }
        ) }

        it { is_expected.to contain_class('apache::mod::worker').with(
          'startservers' => 8,
          'maxclients'   => 256
        ) }

        it { is_expected.not_to contain_class('profiles::apache::metrics') }
      end
    end
  end
end
