describe 'profiles::vault::eks' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'include profiles::vault::install' }

      context 'with no exported clusters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_profiles__vault__eks_cluster_resource_count(0) }
      end

      context 'with clusters from multiple Terraform environments' do
        let(:params) { {
          'clusters' => {
            'publiq-testing' => {
              'environment' => 'testing',
              'oidc_issuer_url' => 'https://oidc.eks.eu-west-1.amazonaws.com/id/TESTING',
              'role_name' => 'external-secrets',
              'bound_audiences' => ['vault'],
              'bound_subject' => 'system:serviceaccount:external-secrets:vault-reader'
            },
            'publiq-production' => {
              'environment' => 'production',
              'oidc_issuer_url' => 'https://oidc.eks.eu-west-1.amazonaws.com/id/PRODUCTION',
              'auth_mount' => 'ignored-exported-mount',
              'role_name' => 'external-secrets',
              'bound_audiences' => ['vault'],
              'bound_subject' => 'system:serviceaccount:external-secrets:vault-reader'
            }
          }
        } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_profiles__vault__eks_cluster_resource_count(2) }
        it { is_expected.to contain_exec('vault EKS auth publiq-production').with_command('/usr/bin/vault auth enable -path=eks-publiq-production jwt') }
        it { is_expected.to contain_profiles__vault__eks_cluster('publiq-testing').with_environment('testing') }
        it { is_expected.to contain_profiles__vault__eks_cluster('publiq-production').with_environment('production') }
        it { is_expected.to contain_profiles__vault__eks_cluster('publiq-testing').that_requires('File[vault_eks_configuration]') }
      end
    end
  end
end
