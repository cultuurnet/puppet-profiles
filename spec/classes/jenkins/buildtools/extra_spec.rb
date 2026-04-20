describe 'profiles::jenkins::buildtools::extra' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('publiq-tools') }

      it { is_expected.to contain_package('mysql-client').with({ 'ensure' => 'present' }) }

      it { is_expected.to contain_package('golang').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('kubectl').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('argocd').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('maven').with({ 'ensure' => 'present' }) }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to contain_package('awscli').with({ 'ensure' => 'latest' }) }
        it { is_expected.to contain_package('terrafile').with({ 'ensure' => 'latest' }) }
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

        it { is_expected.to contain_package('awscli').with({ 'ensure' => 'present' }) }
        it { is_expected.to contain_package('terrafile').with({ 'ensure' => 'present' }) }
      end
    end
  end
end
