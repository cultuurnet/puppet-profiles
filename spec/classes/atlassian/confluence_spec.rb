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
