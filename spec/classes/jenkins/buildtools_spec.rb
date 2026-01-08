describe 'profiles::jenkins::buildtools' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('publiq-tools') }

      it { is_expected.to contain_package('git').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('jq').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('build-essential').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('debhelper').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('golang').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('kubectl').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('argocd').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('mysql-client').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('phantomjs').with({ 'ensure' => 'present' }) }
      it { is_expected.to contain_package('maven').with({ 'ensure' => 'present' }) }

      it { is_expected.to contain_class('profiles::ruby') }
    end
  end
end
