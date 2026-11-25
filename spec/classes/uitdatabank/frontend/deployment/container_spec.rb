describe 'profiles::uitdatabank::frontend::deployment::container' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with ecr_registry => registry.example.com' do
        let(:params) { {
          'ecr_registry' => 'registry.example.com'
        } }

        context 'in the acceptance environment' do
          let(:environment) { 'acceptance' }

          context 'with a docker image version tag available' do
            let(:pre_condition) { 'function ecr_docker_image_version_tag($parameter1, $parameter2) { return "2026.10.07.000000" }' }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::uitdatabank::frontend::deployment::container').with(
              'ecr_registry'   => 'registry.example.com',
              'ecr_repository' => 'uitdatabank/frontend',
              'image_tag'      => '2026.10.07.000000',
              'service_port'   => 4000
            ) }

            it { is_expected.to contain_class('profiles::docker') }

            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with(
              'ensure' => 'file',
              'path'   => '/etc/uitdatabank-frontend/docker-compose.yml',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0644'
            ) }

            it { is_expected.to contain_docker_compose('uitdatabank-frontend').with(
              'ensure'        => 'present',
              'compose_files' => ['/etc/uitdatabank-frontend/docker-compose.yml']
            ) }

            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').that_notifies('Docker_compose[uitdatabank-frontend]') }

            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{^\s+image: registry.example.com/uitdatabank/frontend:2026\.10\.07\.000000$}) }
            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{env_file:}) }
            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{- /etc/uitdatabank-frontend/env$}) }
            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(/^\s+HOSTNAME: "127\.0\.0\.1"$/) }
            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(/^\s+PORT: "4000"$/) }
            it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{wget -q --spider http://127\.0\.0\.1:4000/}) }
          end
        end
      end

      context 'with ecr_registry => myregistry.example.com, ecr_repository => uitdatabank-frontend, image_tag => foo and service_port => 6000' do
        let(:params) { {
          'ecr_registry'   => 'myregistry.example.com',
          'ecr_repository' => 'uitdatabank-frontend',
          'image_tag'      => 'foo',
          'service_port'   => 6000
        } }

        context 'in the testing environment' do
          let(:environment) { 'testing' }

          it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{^\s+image: myregistry.example.com/uitdatabank-frontend:foo$}) }
          it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(/^\s+HOSTNAME: "127\.0\.0\.1"$/) }
          it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(/^\s+PORT: "6000"$/) }
          it { is_expected.to contain_file('uitdatabank-frontend-docker-compose').with_content(%r{wget -q --spider http://127\.0\.0\.1:6000/}) }
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter \$ecr_registry/) }
      end
    end
  end
end
