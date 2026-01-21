describe 'profiles::puppet::puppetserver::puppetdb' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').with(
          'url'     => nil,
          'version' => nil
        ) }

        it { is_expected.not_to contain_apt__source('openvoxdb') }

        it { is_expected.to contain_package('openvoxdb-termini').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver reports').with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'reports'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver storeconfigs').with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'storeconfigs'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver storeconfigs_backend').with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'storeconfigs_backend'
        ) }

        it { is_expected.to contain_file('puppetserver puppetdb.conf').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/puppetdb.conf'
        ) }

        it { is_expected.to contain_file('puppetserver routes.yaml').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/puppet/routes.yaml'
        ) }

        it { is_expected.not_to contain_ini_setting('puppetserver server_urls') }
        it { is_expected.not_to contain_ini_setting('puppetserver soft_write_failure') }
      end

      context "with url => https://foo.example.com:8081" do
        let(:params) { {
          'url' => 'https://foo.example.com:8081'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openvoxdb-termini').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver reports').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'reports',
          'value'   => 'store,puppetdb'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver storeconfigs').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'storeconfigs',
          'value'   => true
        ) }

        it { is_expected.to contain_ini_setting('puppetserver storeconfigs_backend').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'server',
          'setting' => 'storeconfigs_backend',
          'value'   => 'puppetdb'
        ) }

        it { is_expected.to contain_group('puppet') }
        it { is_expected.to contain_user('puppet') }

        it { is_expected.to contain_file('puppetserver puppetdb.conf').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/puppet/puppetdb.conf',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0644'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver server_urls').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppetdb.conf',
          'section' => 'main',
          'setting' => 'server_urls',
          'value'   => 'https://foo.example.com:8081'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver soft_write_failure').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppetdb.conf',
          'section' => 'main',
          'setting' => 'soft_write_failure',
          'value'   => false
        ) }

        it { is_expected.to contain_file('puppetserver routes.yaml').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppetlabs/puppet/routes.yaml',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0644',
          'source'  => 'puppet:///modules/profiles/puppet/puppetserver/routes.yaml'
        ) }

        it { is_expected.to contain_package('openvoxdb-termini').that_requires('Apt::Source[openvox]') }
        it { is_expected.to contain_file('puppetserver puppetdb.conf').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver puppetdb.conf').that_requires('User[puppet]') }
        it { is_expected.to contain_file('puppetserver routes.yaml').that_requires('Group[puppet]') }
        it { is_expected.to contain_file('puppetserver routes.yaml').that_requires('User[puppet]') }
        it { is_expected.to contain_ini_setting('puppetserver server_urls').that_requires('File[puppetserver puppetdb.conf]') }
        it { is_expected.to contain_ini_setting('puppetserver soft_write_failure').that_requires('File[puppetserver puppetdb.conf]') }
      end

      context "with url => https://abc.example.com:1234 and version => 7.2.1" do
        let(:params) { {
          'url'     => 'https://abc.example.com:1234',
          'version' => '7.2.1'
        } }

        it { is_expected.to contain_package('openvoxdb-termini').with(
          'ensure' => '7.2.1'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver server_urls').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppetdb.conf',
          'section' => 'main',
          'setting' => 'server_urls',
          'value'   => 'https://abc.example.com:1234'
        ) }
      end
    end
  end
end
