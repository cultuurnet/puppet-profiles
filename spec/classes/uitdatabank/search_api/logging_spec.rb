describe 'profiles::uitdatabank::search_api::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with servername => foo.example.com' do
        let(:params) { {
          'servername' => 'foo.example.com'
        } }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::logging').with(
            'servername' => 'foo.example.com'
          ) }

          it { is_expected.to contain_class('profiles::filebeat') }

          it { is_expected.to contain_filebeat__input('foo.example.com_uitdatabank::search_api::access').with(
            'paths'    => ['/var/log/apache2/foo.example.com_80_access.log'],
            'doc_type' => 'json',
            'encoding' => 'utf-8',
            'json'     => {
                            'keys_under_root' => true,
                            'add_error_key'   => true
                          },
            'fields'   => {
                            'log_type'    => 'uitdatabank::search_api::access',
                            'environment' => 'acceptance'
                          }
          ) }

          it { expect(exported_resources).to contain_profiles__logstash__filter_fragment('foo.example.com_uitdatabank::search_api::access').with(
            'log_type' => 'uitdatabank::search_api::access',
            'tag'      => 'acceptance'
          ) }

          it { is_expected.to contain_filebeat__input('foo.example.com_uitdatabank::search_api::access').that_requires('Class[profiles::filebeat]') }
        end
      end

      context 'with servername => bar.example.com' do
        let(:params) { {
          'servername' => 'bar.example.com'
        } }

        context 'in the production environment' do
          let(:environment) { 'production' }

          it { is_expected.to contain_class('profiles::uitdatabank::search_api::logging').with(
            'servername' => 'bar.example.com'
          ) }

          it { is_expected.to contain_class('profiles::filebeat') }

          it { is_expected.to contain_filebeat__input('bar.example.com_uitdatabank::search_api::access').with(
            'paths'    => ['/var/log/apache2/bar.example.com_80_access.log'],
            'doc_type' => 'json',
            'encoding' => 'utf-8',
            'json'     => {
                            'keys_under_root' => true,
                            'add_error_key'   => true
                          },
            'fields'   => {
                            'log_type'    => 'uitdatabank::search_api::access',
                            'environment' => 'production'
                          }
          ) }

          it { expect(exported_resources).to contain_profiles__logstash__filter_fragment('bar.example.com_uitdatabank::search_api::access').with(
            'log_type' => 'uitdatabank::search_api::access',
            'tag'      => 'production'
          ) }

          it { is_expected.to contain_filebeat__input('bar.example.com_uitdatabank::search_api::access').that_requires('Class[profiles::filebeat]') }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
