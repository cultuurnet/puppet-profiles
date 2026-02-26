describe 'profiles::puppet::agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::puppet::agent').with(
          'version'             => 'installed',
          'puppetserver'        => nil,
          'commandline_options' => '',
          'service_status'      => 'stopped',
        ) }

        it { is_expected.to contain_apt__source('openvox') }

        it { is_expected.to contain_package('openvox-agent').with(
          'ensure'    => 'installed'
        ) }

        it { is_expected.to contain_file('puppet agent service defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/puppet',
          'content' => "PUPPET_EXTRA_OPTS=''"
        ) }

        it { is_expected.to contain_file('puppet agent production environment hiera.yaml').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/code/environments/production/hiera.yaml'
        ) }

        it { is_expected.to contain_file('puppet agent production environment datadir').with(
          'ensure' => 'absent',
          'path'   => '/etc/puppetlabs/code/environments/production/data',
          'force'  => true
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'stopped',
          'enable'    => false,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_ini_setting('puppetserver').with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'main',
          'setting' => 'server'
        ) }

        it { is_expected.to contain_ini_setting('agent certificate_revocation').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'certificate_revocation',
          'value'   => false
        ) }

        it { is_expected.to contain_ini_setting('agent usecacheonfailure').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'agent',
          'setting' => 'usecacheonfailure',
          'value'   => false
        ) }

        it { is_expected.to contain_ini_setting('agent reports').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'main',
          'setting' => 'reports',
          'value'   => 'store',
        ) }

        it { is_expected.to contain_apt__source('openvox').that_comes_before('Package[openvox-agent]') }
        it { is_expected.to contain_package('openvox-agent').that_requires('File[/etc/puppetlabs/facter/facts.d]') }
        it { is_expected.to contain_package('openvox-agent').that_notifies('Service[puppet]') }
        it { is_expected.to contain_file('puppet agent service defaults').that_requires('Package[openvox-agent]') }
        it { is_expected.to contain_file('puppet agent service defaults').that_notifies('Service[puppet]') }
        it { is_expected.to contain_file('puppet agent production environment hiera.yaml').that_requires('Package[openvox-agent]') }
        it { is_expected.to contain_file('puppet agent production environment datadir').that_requires('Package[openvox-agent]') }
        it { is_expected.to contain_ini_setting('agent certificate_revocation').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent usecacheonfailure').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('agent reports').that_notifies('Service[puppet]') }
        it { is_expected.to contain_ini_setting('puppetserver').that_notifies('Service[puppet]') }
      end

      context "with version => 6.23.1, puppetserver => puppet.example.com, commandline_options => --debug --noop and service_status => running" do
        let(:params) { {
          'version'             => '6.23.1',
          'puppetserver'        => 'puppet.example.com',
          'commandline_options' => '--debug --noop',
          'service_status'      => 'running'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openvox-agent').with(
          'ensure'    => '6.23.1'
        ) }

        it { is_expected.to contain_file('puppet agent service defaults').with(
          'ensure'  => 'file',
          'path'    => '/etc/default/puppet',
          'content' => "PUPPET_EXTRA_OPTS='--debug --noop'"
        ) }

        it { is_expected.to contain_service('puppet').with(
          'ensure'    => 'running',
          'enable'    => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_ini_setting('puppetserver').with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppet/puppet.conf',
          'section' => 'main',
          'setting' => 'server',
          'value'   => 'puppet.example.com'
        ) }

        it { is_expected.to contain_ini_setting('puppetserver').that_notifies('Service[puppet]') }
      end

      context "on AWS EC2" do
        let(:facts) do
          super().merge({ 'ec2_metadata' => 'true'})
        end

        context "with environment set to 'foobar' and trusted_facts pp_environment set to development" do
          let(:environment) { 'foobar' }
          let(:trusted_facts) { { 'pp_environment' => 'development' } }

          # The trusted facts override the environment setting
          it { is_expected.to contain_ini_setting('environment').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'main',
            'setting' => 'environment',
            'value'   => 'development'
          ) }

          it { is_expected.to contain_ini_setting('environment').that_notifies('Service[puppet]') }
        end

        context "with environment from trusted facts" do
          let(:trusted_facts) { { 'pp_environment' => 'acceptance' } }

          it { is_expected.to contain_ini_setting('environment').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'main',
            'setting' => 'environment',
            'value'   => 'acceptance'
          ) }
        end
      end

      context "not on AWS EC2" do
        let(:facts) do
          super()
        end

        it { is_expected.not_to contain_ini_setting('environment') }
      end
    end
  end
end
