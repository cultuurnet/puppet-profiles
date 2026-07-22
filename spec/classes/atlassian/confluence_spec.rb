describe 'profiles::atlassian::confluence' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:params) { {
        'servername'        => 'confluence.example.com',
        'version'           => '9.2.1',
        'java_opts'         => '-Djava.awt.headless=true',
        'database_password' => 'secret'
      } }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }

      it { is_expected.to contain_file('/home/confluence/upmconfig').with(
        'ensure' => 'directory',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755'
      ) }

      it { is_expected.to contain_file('/home/confluence/upmconfig/truststore').with(
        'ensure' => 'directory',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755'
      ) }

      it { is_expected.to contain_file('/home/confluence/upmconfig/truststore').that_requires('File[/home/confluence/upmconfig]') }

      [
        'atlassian_mpac_intermediate_ca_v1.crt',
        'atlassian_mpac_intermediate_ca_v2.crt',
        'atlassian_mpac_root_ca_v1.crt'
      ].each do |certificate|
        it { is_expected.to contain_file("/home/confluence/upmconfig/truststore/#{certificate}").with(
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'source' => "puppet:///modules/profiles/atlassian/confluence/upmconfig/truststore/#{certificate}"
        ) }

        it { is_expected.to contain_file("/home/confluence/upmconfig/truststore/#{certificate}").that_requires('File[/home/confluence/upmconfig/truststore]') }
      end

      context 'with cleanup_old_versions disabled (default)' do
        let(:facts) { facts.merge('confluence_installed_versions' => ['atlassian-confluence-9.2.1', 'atlassian-confluence-9.1.0']) }

        it { is_expected.not_to contain_file('/opt/confluence/atlassian-confluence-9.1.0') }
      end

      context 'with cleanup_old_versions enabled' do
        let(:params) { super().merge('cleanup_old_versions' => true) }
        let(:facts) { facts.merge('confluence_installed_versions' => [
          'atlassian-confluence-9.2.1',
          'atlassian-confluence-9.1.0',
          'atlassian-confluence-9.0.5'
        ]) }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file('/opt/confluence/atlassian-confluence-9.0.5').with(
          'ensure' => 'absent',
          'force'  => true
        ).that_requires('Class[confluence]') }

        # 9.1.0 is the one previous version kept for rollback (versions_to_keep defaults to 1)
        it { is_expected.not_to contain_file('/opt/confluence/atlassian-confluence-9.1.0').with('ensure' => 'absent') }
        # the current version must never be touched by cleanup
        it { is_expected.not_to contain_file('/opt/confluence/atlassian-confluence-9.2.1').with('ensure' => 'absent') }

        context 'with versions_to_keep set to 0' do
          let(:params) { super().merge('versions_to_keep' => 0) }

          it { is_expected.to contain_file('/opt/confluence/atlassian-confluence-9.1.0').with('ensure' => 'absent') }
          it { is_expected.to contain_file('/opt/confluence/atlassian-confluence-9.0.5').with('ensure' => 'absent') }
          it { is_expected.not_to contain_file('/opt/confluence/atlassian-confluence-9.2.1').with('ensure' => 'absent') }
        end
      end
    end
  end
end
