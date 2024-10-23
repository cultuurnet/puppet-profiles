describe 'profiles' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with Terraform integration enabled and data available' do
        let(:hiera_config) { 'spec/support/hiera/terraform_available.yaml' }

        it { is_expected.to contain_class('profiles::stages') }
        it { is_expected.to contain_class('profiles::apt') }
        it { is_expected.to contain_class('profiles::groups') }
        it { is_expected.to contain_class('profiles::users') }
        it { is_expected.to contain_class('profiles::files') }

        it { is_expected.to contain_class('profiles::apt::repositories').with(
          'stage' => 'pre'
        ) }
      end

      context 'with Terraform integration enabled and data unavailable' do
        let(:hiera_config) { 'spec/support/hiera/terraform_unavailable.yaml' }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /Terraform integration enabled but hieradata not available/) }
      end

      context 'with Terraform integration not enabled' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        it { is_expected.to contain_class('profiles::stages') }
        it { is_expected.to contain_class('profiles::apt') }
        it { is_expected.to contain_class('profiles::groups') }
        it { is_expected.to contain_class('profiles::users') }
        it { is_expected.to contain_class('profiles::files') }

        it { is_expected.to contain_class('profiles::apt::repositories').with(
          'stage' => 'pre'
        ) }
      end
    end
  end
end
