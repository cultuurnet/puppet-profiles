describe 'profiles::aws_cli' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('publiq-tools') }

      it { is_expected.to contain_class('profiles::aws_cli') }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml'}

        it { is_expected.to contain_package('awscli').with(
          'ensure' => 'latest'
        ) }
      end

      context 'without hieradata' do
        let(:hiera_config) { 'spec/support/hiera/empty.yaml'}

        it { is_expected.to contain_package('awscli').with(
          'ensure' => 'present'
        ) }
      end

      it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[awscli]') }
    end
  end
end
