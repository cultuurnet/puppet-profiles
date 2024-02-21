describe 'profiles::collectd' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host aaa.example.com" do
        let(:node) { 'aaa.example.com' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::collectd').with(
            'enable'        => true,
            'graphite_host' => nil
          ) }

          it { is_expected.to contain_collectd__typesdb('/etc/collectd/types.db').with(
            'path' => '/etc/collectd/types.db'
          ) }

          it { is_expected.to contain_class('collectd').with(
            'manage_repo'       => false,
            'package_name'      => 'collectd-core',
            'minimum_version'   => '5.8',
            'purge'             => true,
            'purge_config'      => true,
            'recurse'           => true,
            'fqdnlookup'        => false,
            'service_ensure'    => 'running',
            'service_enable'    => true,
            'collectd_hostname' => 'aaa.example.com',
            'typesdb'           => [ '/usr/share/collectd/types.db', '/etc/collectd/types.db']
          ) }

          it { is_expected.to contain_class('collectd::plugin::cpu') }
          it { is_expected.to contain_class('collectd::plugin::disk') }
          it { is_expected.to contain_class('collectd::plugin::interface') }
          it { is_expected.to contain_class('collectd::plugin::load') }
          it { is_expected.to contain_class('collectd::plugin::memory') }
          it { is_expected.to contain_class('collectd::plugin::processes') }
          it { is_expected.to contain_class('collectd::plugin::vmem') }

          it { is_expected.to contain_class('collectd::plugin::df').with(
            'fstypes' => ['ext4']
          ) }

          it { is_expected.not_to contain_class('collectd::plugin::write_graphite') }
        end

        context "with graphite_host => graphite.example.com" do
          let(:params) { { 'graphite_host' => 'graphite.example.com' }}


          it { is_expected.to contain_class('collectd::plugin::write_graphite').with(
            'carbons' => { 'graphite.example.com' => {'graphitehost' => 'graphite.example.com'} }
          ) }
        end
      end

      context "on host bbb.example.com" do
        let(:node) { 'bbb.example.com' }

        context "with graphite_host => graphite2.example.com and enable => false" do
          let(:params) { {
            'enable'        => false,
            'graphite_host' => 'graphite2.example.com'
          } }

          it { is_expected.to contain_class('collectd').with(
            'manage_repo'       => false,
            'package_name'      => 'collectd-core',
            'minimum_version'   => '5.8',
            'purge'             => true,
            'purge_config'      => true,
            'recurse'           => true,
            'fqdnlookup'        => false,
            'service_ensure'    => 'stopped',
            'service_enable'    => false,
            'collectd_hostname' => 'bbb.example.com',
            'typesdb'           => [ '/usr/share/collectd/types.db', '/etc/collectd/types.db']
          ) }

          it { is_expected.to contain_class('collectd::plugin::write_graphite').with(
            'carbons' => { 'graphite2.example.com' => {'graphitehost' => 'graphite2.example.com'} }
          ) }
        end
      end
    end
  end
end
