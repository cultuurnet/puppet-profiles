describe 'profiles::uitpas::api::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { { 'servername' => 'api.example.com' } }

      ['testing', 'acceptance', 'production'].each do |environment|
        context "in #{environment}" do
          let(:environment) { environment }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_filebeat__input('api.example.com_uitpas::api').with(
            'input_type'    => 'filestream',
            'paths'         => ['/opt/payara/glassfish/domains/uitpas/logs/server.log*'],
            'exclude_files' => ['\.gz$'],
            'ignore_older'  => nil,
            'fields'        => {
              'log_type'    => 'uitpas::api',
              'environment' => environment,
              'servername'  => 'api.example.com',
            }
          ).that_requires('Class[profiles::filebeat]') }

          it 'renders a filestream multiline parser with a stable input ID' do
            content = catalogue.resource('File', 'filebeat-api.example.com_uitpas::api')[:content]
            input = YAML.safe_load(content).first
            expect(input['id']).to eq('api.example.com_uitpas::api')
            expect(input['parsers']).to eq([{
              'multiline' => {
                'pattern'   => '^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T',
                'negate'    => true,
                'match'     => 'after',
                'max_lines' => 2000,
                'timeout'   => '5s',
              }
            }])
            expect(input.dig('prospector', 'scanner', 'exclude_files')).to eq(['\.gz$'])
          end
        end
      end

      context 'with a custom history window' do
        let(:params) { super().merge('ignore_older' => '48h') }
        it { is_expected.to contain_filebeat__input('api.example.com_uitpas::api').with_ignore_older('48h') }
      end
    end
  end
end
