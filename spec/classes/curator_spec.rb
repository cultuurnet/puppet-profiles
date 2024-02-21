describe 'profiles::curator' do
  context "with articlelinker_config_source => /foo, articlelinker_publishers_source => /bar and articlelinker_env_defaults_source => /defaults" do
    let(:params) { {
      'articlelinker_config_source'       => '/foo',
      'articlelinker_publishers_source'   => '/bar',
      'articlelinker_env_defaults_source' => '/defaults',
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        context "with the noop_deploy fact set to true" do
          let(:facts) do
            super().merge({ 'noop_deploy' => 'true' })
          end

          it { is_expected.not_to contain_class('profiles::deployment::curator::articlelinker') }
        end

        it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
          'config_source'       => '/foo',
          'publishers_source'   => '/bar',
          'version'             => 'latest',
          'env_defaults_source' => '/defaults',
          'service_manage'      => true,
          'service_ensure'      => 'running',
          'service_enable'      => true
        ) }

        context "with articlelinker_service_manage => false, articlelinker_service_ensure => stopped and articlelinker_service_enable => false" do
          let(:params) {
            super().merge({
              'articlelinker_service_manage' => false,
              'articlelinker_service_ensure' => 'stopped',
              'articlelinker_service_enable' => false
            } )
          }

          it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
            'config_source'       => '/foo',
            'publishers_source'   => '/bar',
            'version'             => 'latest',
            'env_defaults_source' => '/defaults',
            'service_manage'      => false,
            'service_ensure'      => 'stopped',
            'service_enable'      => false
          ) }
        end

        context "with articlelinker_version => 9.8.7" do
          let(:params) {
            super().merge({
              'articlelinker_version' => '9.8.7'
            } )
          }

          it { is_expected.to contain_class('profiles::deployment::curator::articlelinker').with(
            'version'      => '9.8.7'
          ) }
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_publishers_source'/) }
      end
    end
  end
end
