describe 'profiles::newrelic::infrastructure' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        context 'with hieradata' do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::newrelic::infrastructure').with(
            'license_key'    => 'my_license_key',
            'version'        => 'latest',
            'service_status' => 'running',
            'log_level'      => 'info',
            'attributes'     => {}
          ) }

          it { is_expected.to contain_class('profiles::newrelic::infrastructure::install').with(
            'version' => 'latest'
          ) }

          it { is_expected.to contain_class('profiles::newrelic::infrastructure::configuration').with(
            'license_key' => 'my_license_key',
            'log_level'   => 'info',
            'attributes'  => {}
          ) }

          it { is_expected.to contain_class('profiles::newrelic::infrastructure::service').with(
            'status' => 'running'
          ) }

          it { is_expected.to contain_class('profiles::newrelic::infrastructure::install').that_comes_before('Class[profiles::newrelic::infrastructure::configuration]') }
          it { is_expected.to contain_class('profiles::newrelic::infrastructure::configuration').that_notifies('Class[profiles::newrelic::infrastructure::service]') }
        end

        context 'without hieradata' do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'license_key'/) }
        end
      end

      context 'with license_key => secret, version => 1.2.3, service_status => stopped, log_level => debug and attributes => { foo => true, bar => false }' do
        let(:params) { {
          'license_key'    => 'secret',
          'version'        => '1.2.3',
          'service_status' => 'stopped',
          'log_level'      => 'debug',
          'attributes'     => { 'foo' => true, 'bar' => false }
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::newrelic::infrastructure::install').with(
          'version' => '1.2.3'
        ) }

        it { is_expected.to contain_class('profiles::newrelic::infrastructure::configuration').with(
          'license_key' => 'secret',
          'log_level'   => 'debug',
          'attributes'  => { 'foo' => true, 'bar' => false }
        ) }

        it { is_expected.to contain_class('profiles::newrelic::infrastructure::service').with(
          'status' => 'stopped'
        ) }
      end
    end
  end
end
