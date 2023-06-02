require 'spec_helper'

describe 'profiles::icinga2' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host aaa.example.com with ipaddress 1.2.3.4 in the acceptance environment" do
        let(:node) { 'aaa.example.com' }
        let(:environment) { 'acceptance' }

        let(:facts) {
          super().merge(
            'networking' => { 'ip' => '1.2.3.4' }
          )
        }

        context "without parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_firewall('200 accept NRPE traffic') }

          it { is_expected.to contain_class('profiles::icinga2').with(
            'nrpe_allowed_hosts' => []
          ) }

          it { is_expected.to contain_class('icinga2::nrpe').with(
            'nrpe_allowed_hosts' => ['127.0.0.1', '1.2.3.4']
          ) }

          it { is_expected.to contain_icinga2__nrpe__command('check_disk').with(
          'nrpe_plugin_args' => '-w $ARG1$ -c $ARG2$ -p $ARG3$',
          'nrpe_plugin_name' => 'check_disk'
          ) }

          it { is_expected.to contain_icinga2__nrpe__command('check_diskstats').with(
            'nrpe_plugin_args' => '-w10% -c5% --all',
            'nrpe_plugin_name' => 'check_disk'
          ) }

          case facts[:os]['release']['major']
          when '14.04'
            it { is_expected.to_not contain_package('icinga2-plugins-systemd-service') }
          when '16.04'
            it { is_expected.to contain_apt__source('publiq-tools') }
            it { is_expected.to contain_package('icinga2-plugins-systemd-service').with(
              'ensure' => 'present'
            ) }

            it { is_expected.to contain_package('icinga2-plugins-systemd-service').that_requires('Apt::Source[publiq-tools]') }
          end

          it { expect(exported_resources).to contain_icinga2__object__host('aaa.example.com').with(
            'display_name'     => 'aaa.example.com',
            'target_dir'       => '/etc/icinga2/objects/hosts',
            'target_file_name' => 'aaa.example.com.conf',
            'ipv4_address'     => '1.2.3.4',
            'vars'             => {
                                    'distro'             => 'Ubuntu',
                                    'os'                 => 'Linux',
                                    'virtual_machine'    => true,
                                    'puppet_certname'    => 'aaa.example.com',
                                    'puppet_environment' => 'acceptance'
                                  }
          ) }
        end

        context "with nrpe_allowed_hosts => '5.6.7.8'" do
          let(:params) { {
            'nrpe_allowed_hosts' => '5.6.7.8'
          } }

          it { is_expected.to contain_class('icinga2::nrpe').with(
            'nrpe_allowed_hosts' => ['127.0.0.1', '1.2.3.4', '5.6.7.8']
          ) }
        end
      end

      context "on host bbb.example.com with ipaddress 4.3.2.1 in the testing environment" do
        let(:node) { 'bbb.example.com' }
        let(:environment) { 'testing' }

        let(:facts) {
          super().merge(
            'networking' => { 'ip' => '4.3.2.1' }
          )
        }

        context "with nrpe_allowed_hosts => ['8.7.6.5', '9.10.11.12']" do
          let(:params) { {
            'nrpe_allowed_hosts' => ['8.7.6.5', '9.10.11.12']
          } }

          it { is_expected.to contain_class('icinga2::nrpe').with(
            'nrpe_allowed_hosts' => ['127.0.0.1', '4.3.2.1', '8.7.6.5', '9.10.11.12']
          ) }

          it { expect(exported_resources).to contain_icinga2__object__host('bbb.example.com').with(
            'display_name'     => 'bbb.example.com',
            'target_dir'       => '/etc/icinga2/objects/hosts',
            'target_file_name' => 'bbb.example.com.conf',
            'ipv4_address'     => '4.3.2.1',
            'vars'             => {
                                    'distro'             => 'Ubuntu',
                                    'os'                 => 'Linux',
                                    'virtual_machine'    => true,
                                    'puppet_certname'    => 'bbb.example.com',
                                    'puppet_environment' => 'testing'
                                  }
          ) }
        end
      end
    end
  end
end
