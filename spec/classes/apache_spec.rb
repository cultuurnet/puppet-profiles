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
          'service_status'    => 'running',
          'metrics'           => true
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('apache').with(
          'mpm_module'     => false,
          'manage_group'   => false,
          'manage_user'    => false,
          'default_vhost'  => true,
          'service_manage' => true,
          'service_ensure' => 'running',
          'service_enable' => true
        ) }

        it { is_expected.to contain_class('apache::mod::prefork') }

        it { is_expected.to contain_class('profiles::apache::metrics') }
        it { is_expected.to contain_class('profiles::apache::logging') }

        it { is_expected.to contain_apache__mod('unique_id') }

        it { is_expected.to contain_group('www-data').that_comes_before('Class[apache]') }
        it { is_expected.to contain_user('www-data').that_comes_before('Class[apache]') }
      end

      context "with mpm_module => worker, mpm_module_config => { startservers => 8, maxclients => 256 }, service_status => stopped and metrics => false" do
        let(:params) { {
          'mpm_module'        => 'worker',
          'mpm_module_config' => { 'startservers' => 8, 'maxclients' => 256 },
          'service_status'    => 'stopped',
          'metrics'           => false
        } }

        it { is_expected.to contain_class('apache').with(
          'mpm_module'     => false,
          'manage_group'   => false,
          'manage_user'    => false,
          'default_vhost'  => true,
          'service_manage' => true,
          'service_ensure' => 'stopped',
          'service_enable' => false
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
