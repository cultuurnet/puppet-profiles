describe 'profiles::ssh::service' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_service('ssh').with(
        'ensure' => 'running',
        'enable' => true
      ) }
    end
  end
end
