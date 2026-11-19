require 'json'

describe 'profiles::vault::eks_cluster' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'publiq-testing' }
      let(:params) { {
        'environment' => 'testing',
        'oidc_issuer_url' => 'https://oidc.eks.eu-west-1.amazonaws.com/id/TESTING',
        'auth_mount' => 'eks-publiq-testing',
        'role_name' => 'external-secrets',
        'bound_audiences' => ['vault'],
        'bound_subject' => 'system:serviceaccount:external-secrets:vault-reader'
      } }

      it { is_expected.to compile.with_all_deps }

      it 'grants access only to the exported environment, independently of the server environment' do
        policy = catalogue.resource('File', 'vault EKS policy publiq-testing')[:content]
        expect(policy.scan(/path "([^"]+)"/).flatten).to match_array([
          'puppet/data/testing', 'puppet/data/testing/*',
          'puppet/metadata/testing', 'puppet/metadata/testing/*',
          'auth/token/lookup-self', 'auth/token/renew-self', 'auth/token/revoke-self'
        ])
        expect(policy).not_to match(/production|acceptance|"create"|"delete"|"patch"|"sudo"/)
      end

      it 'pins issuer discovery and the expected issuer to this cluster' do
        data = JSON.parse(catalogue.resource('File', 'vault EKS config publiq-testing')[:content])
        expect(data).to eq({
          'oidc_discovery_url' => params['oidc_issuer_url'],
          'bound_issuer' => params['oidc_issuer_url']
        })
      end

      it 'binds the exact subject/audience and issues only the scoped policy without default policy' do
        data = JSON.parse(catalogue.resource('File', 'vault EKS role publiq-testing')[:content])
        expect(data).to include(
          'role_type' => 'jwt', 'user_claim' => 'sub',
          'bound_subject' => 'system:serviceaccount:external-secrets:vault-reader',
          'bound_audiences' => ['vault'],
          'token_policies' => ['eso-publiq-testing-read-only'],
          'token_no_default_policy' => true,
          'token_ttl' => 600, 'token_max_ttl' => 600
        )
      end

      it 'checks remote drift each run instead of depending only on file refresh events' do
        %w[policy auth config role].each do |part|
          exec = catalogue.resource('Exec', "vault EKS #{part} publiq-testing")
          expect(exec[:user]).to eq('vault')
          expect(exec[:unless]).not_to be_empty
          expect(exec[:refreshonly]).not_to eq(true)
        end
      end

      it { is_expected.to contain_exec('vault EKS config publiq-testing').that_requires('Exec[vault EKS auth publiq-testing]') }
      it { is_expected.to contain_exec('vault EKS role publiq-testing').that_requires('Exec[vault EKS policy publiq-testing]') }
      it { is_expected.to contain_exec('vault EKS role publiq-testing').that_requires('Exec[vault EKS config publiq-testing]') }

      %w[acceptance production].each do |environment|
        context "with exported environment #{environment}" do
          let(:params) { super().merge('environment' => environment) }

          it 'uses metadata rather than inferring permissions from the cluster name' do
            policy = catalogue.resource('File', 'vault EKS policy publiq-testing')[:content]
            expect(policy).to include("puppet/data/#{environment}/*", "puppet/metadata/#{environment}/*")
            expect(policy).not_to include('puppet/data/testing', 'puppet/metadata/testing')
          end
        end
      end

      ['*', '../production', 'test', 'testing/*', ''].each do |environment|
        context "with invalid environment #{environment.inspect}" do
          let(:params) { super().merge('environment' => environment) }
          it { is_expected.not_to compile }
        end
      end

      context 'without environment metadata' do
        let(:params) { super().reject { |key, _| key == 'environment' } }
        it { is_expected.not_to compile }
      end

      context 'with another cluster auth mount' do
        let(:params) { super().merge('auth_mount' => 'eks-publiq-production') }
        it { is_expected.to compile.and_raise_error(/auth_mount must be eks-publiq-testing/) }
      end

      context 'with a wildcard subject' do
        let(:params) { super().merge('bound_subject' => 'system:serviceaccount:*:*') }
        it { is_expected.not_to compile }
      end

      context 'with a wildcard audience' do
        let(:params) { super().merge('bound_audiences' => ['*']) }
        it { is_expected.not_to compile }
      end

      context 'with an insecure issuer' do
        let(:params) { super().merge('oidc_issuer_url' => 'http://example.com') }
        it { is_expected.not_to compile }
      end
    end
  end
end
