describe 'profiles::newrelic::infrastructure::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node mynode.example.com' do
        let(:node) { 'mynode.example.com' }

        context 'on AWS EC2 in the acceptance environment' do
          let(:environment) { 'acceptance' }
          let(:facts) { facts.merge( { 'ec2_metadata' => {} } ) }

          context 'with license_key => my_license_key' do
            let(:params) { {
              'license_key' => 'my_license_key'
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::newrelic::infrastructure::configuration').with(
              'license_key' => 'my_license_key',
              'log_level'   => 'info',
              'attributes'  => {}
            ) }

            it { is_expected.to contain_file('/etc/newrelic-infra/integrations.d').with(
              'ensure'  => 'directory',
              'recurse' => true,
              'purge'   => true
            ) }

            it { is_expected.to contain_file('/etc/newrelic-infra/logging.d').with(
              'ensure'  => 'directory',
              'recurse' => true,
              'purge'   => true
            ) }

            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0640'
            ) }

            it { is_expected.to contain_systemd__unit_file('newrelic-infra.service').with(
              'ensure' => 'present',
              'enable' => true,
              'active' => true,
              'source' => 'puppet:///modules/profiles/newrelic/newrelic-infra.service'
            ) }

            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^license_key: my_license_key$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^display_name: mynode.example.com$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^dns_hostname_resolution: false$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^pid_file: \/run\/newrelic-infra\/newrelic-infra\.pid$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^cloud_provider: aws$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^custom_attributes:\n\s{2}environment: acceptance$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^log:\n\s{2}level: info$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^\s{2}rotate:\n\s{4}max_size_mb: 100\n\s{4}max_files: 10$/) }
          end

          context 'without parameters' do
            let(:params) { {} }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'license_key'/) }
          end
        end
      end

      context 'on node mynode.example.com' do
        let(:node) { 'test.example.com' }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          context 'with license_key => foobar, log_level => debug and attributes => { project => foo, size => small }' do
            let(:params) { {
              'license_key' => 'foobar',
              'log_level'   => 'debug',
              'attributes'  => { 'project' => 'foo', 'size' => 'small' }
            } }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^license_key: foobar$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^display_name: test.example.com$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^dns_hostname_resolution: false$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^pid_file: \/run\/newrelic-infra\/newrelic-infra\.pid$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^custom_attributes:\n\s{2}environment: testing\n\s{2}project: foo\n\s{2}size: small$/) }
            it { is_expected.to contain_file('/etc/newrelic-infra.yml').with_content(/^log:\n\s{2}level: debug$/) }

            it { is_expected.not_to contain_file('/etc/newrelic-infra.yml').with_content(/^cloud_provider: aws$/) }
          end
        end
      end
    end
  end
end
