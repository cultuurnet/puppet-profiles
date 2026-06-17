describe 'profiles::atlassian::confluence' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:pre_condition) { [
        "Apt::Source <| title == 'publiq-tools' |>",
        "Package <| title == 'mysql-connector-j' |>",
        <<~PUPPET
          class confluence (
            String $version,
            String $installdir,
            String $homedir,
            Boolean $manage_homedir,
            Integer $tomcat_port,
            Boolean $manage_user,
            String $javahome,
            String $jvm_type,
            Boolean $mysql_connector,
            String $jvm_xms,
            String $jvm_xmx,
            String $java_opts,
            Boolean $manage_service,
            Hash $tomcat_proxy
          ) {}

          define confluence::conf (
            String $value
          ) {}
        PUPPET
      ] }

      let(:params) { {
        'servername'        => 'confluence.example.com',
        'version'           => '9.2.1',
        'java_opts'         => '-Djava.awt.headless=true',
        'database_password' => 'secret'
      } }

      it { is_expected.to compile.with_all_deps }

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
    end
  end
end
