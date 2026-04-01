describe 'profiles::jenkins::container_agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::jenkins::container_agent').with() }

      it { is_expected.to contain_class('profiles::jenkins::node') }
      it { is_expected.to contain_class('profiles::docker') }

      it { is_expected.to contain_package('git') }
    end
  end
end
