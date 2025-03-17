describe 'profiles::aws_cli' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::aws_cli').with(
          'version'           => 'latest',
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('aws-cli').with(
          'ensure' => 'latest'
        ) }

    
        it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[aws-cli]') }
      end

    end
  end
end
