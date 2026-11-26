describe 'profiles::uitdatabank::frontend::logging' do
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

          it { is_expected.to contain_class('profiles::filebeat') }

          it { is_expected.to contain_filebeat__input('foo.example.com_uitdatabank::frontend::app').with(
            'input_type' => 'log',
            'paths'      => ['/var/lib/docker/containers/*/*-json.log'],
            'doc_type'   => 'log',
            'json'       => {
                              'message_key'   => 'log',
                              'add_error_key' => true
                            },
            'fields'     => {
                              'log_type'    => 'uitdatabank::frontend::app',
                              'environment' => 'acceptance'
                            },
            'processors' => [
                              {
                                'add_docker_metadata' => {
                                  'host' => 'unix:///var/run/docker.sock'
                                }
                              }
                            ]
          ) }

          it { is_expected.to contain_filebeat__input('foo.example.com_uitdatabank::frontend::app').that_requires('Class[profiles::filebeat]') }
        end
      end

      context 'with servername => bar.example.com' do
        let(:params) { {
          'servername' => 'bar.example.com'
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.to contain_filebeat__input('bar.example.com_uitdatabank::frontend::app').with(
            'fields' => {
                          'log_type'    => 'uitdatabank::frontend::app',
                          'environment' => 'testing'
                        }
          ) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'servername'/) }
      end
    end
  end
end
