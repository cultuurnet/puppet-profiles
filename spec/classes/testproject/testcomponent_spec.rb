describe 'profiles::testproject::testcomponent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'with config_source' do
          let(:params) { {
            'config_source' => 'appconfig/testproject/testcomponent/config.json'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('testproject config_file').with(
            'ensure' => 'file',
            'path'   => '/tmp/testproject.json'
          ) }

          # Specs for the content of the configuration file are somewhat beyond
          # the scope of this module, as the content of it is dependent on what
          # is provided through the config_source parameter. It is merely
          # included here to show the lookup of the secrets is working.
          it { is_expected.to contain_file('testproject config_file').with_content(/"my_first_secret": "abc123"/) }
          it { is_expected.to contain_file('testproject config_file').with_content(/"my_second_secret": "def456"/) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
