describe 'profiles::uitdatabank::frontend::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {
        'config_source' => 'appconfig/uitdatabank/udb3-frontend/env'
      } }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with type => instance (the default)' do
          let(:pre_condition) { "class { 'profiles::uitdatabank::frontend': servername => 'frontend.example.com', deployment => false }" }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment').with(
            'config_source'   => 'appconfig/uitdatabank/udb3-frontend/env',
            'service_address' => '127.0.0.1',
            'service_port'    => 4000
          ) }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment::instance').with(
            'config_source'   => 'appconfig/uitdatabank/udb3-frontend/env',
            'service_address' => '127.0.0.1',
            'service_port'    => 4000
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::frontend::deployment::container') }
        end

        context 'with type => container' do
          let(:pre_condition) { "class { 'profiles::uitdatabank::frontend': servername => 'frontend.example.com', deployment => false, type => 'container' }" }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment::container').with(
            'config_source'   => 'appconfig/uitdatabank/udb3-frontend/env',
            'service_address' => '127.0.0.1',
            'service_port'    => 4000
          ) }

          it { is_expected.not_to contain_class('profiles::uitdatabank::frontend::deployment::instance') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
