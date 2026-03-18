describe 'profiles::rsyslog' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('profiles::rsyslog').with() }

      it { is_expected.to contain_class('rsyslog').with(
        'target_file' => '00_rsyslog.conf'
      ) }

      it { is_expected.to contain_class('rsyslog::config') }
    end
  end
end
