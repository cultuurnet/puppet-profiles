describe 'profiles::atlassian::jira' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:pre_condition) { "volume_group { 'datavg': ensure => present }\nrealize Apt::Source['publiq-tools']\nrealize Package['mysql-connector-j']" }

      let(:params) { {
        'servername'        => 'jira.example.com',
        'version'           => '10.3.7',
        'java_opts'         => '-Djava.awt.headless=true',
        'database_password' => 'secret',
        'lvm'               => true,
        'volume_group'      => 'datavg',
        'volume_size'       => '40G'
      } }

      it { is_expected.to compile.with_all_deps }

      context 'with cleanup_old_versions disabled (default)' do
        let(:facts) { facts.merge('jira_installed_versions' => [
          'atlassian-jira-software-10.3.7-standalone',
          'atlassian-jira-software-10.3.6-standalone'
        ]) }

        it { is_expected.not_to contain_file('/opt/jira/atlassian-jira-software-10.3.6-standalone').with('ensure' => 'absent') }
      end

      context 'with cleanup_old_versions enabled' do
        let(:params) { super().merge('cleanup_old_versions' => true) }
        let(:facts) { facts.merge('jira_installed_versions' => [
          'atlassian-jira-software-10.3.7-standalone',
          'atlassian-jira-software-10.3.6-standalone',
          'atlassian-jira-software-10.3.5-standalone'
        ]) }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file('/opt/jira/atlassian-jira-software-10.3.5-standalone').with(
          'ensure' => 'absent',
          'force'  => true
        ).that_requires('Class[jira]') }

        # 10.3.6 is the one previous version kept for rollback (versions_to_keep defaults to 1)
        it { is_expected.not_to contain_file('/opt/jira/atlassian-jira-software-10.3.6-standalone').with('ensure' => 'absent') }
        # the current version must never be touched by cleanup
        it { is_expected.not_to contain_file('/opt/jira/atlassian-jira-software-10.3.7-standalone').with('ensure' => 'absent') }

        context 'with versions_to_keep set to 0' do
          let(:params) { super().merge('versions_to_keep' => 0) }

          it { is_expected.to contain_file('/opt/jira/atlassian-jira-software-10.3.6-standalone').with('ensure' => 'absent') }
          it { is_expected.to contain_file('/opt/jira/atlassian-jira-software-10.3.5-standalone').with('ensure' => 'absent') }
          it { is_expected.not_to contain_file('/opt/jira/atlassian-jira-software-10.3.7-standalone').with('ensure' => 'absent') }
        end
      end
    end
  end
end
