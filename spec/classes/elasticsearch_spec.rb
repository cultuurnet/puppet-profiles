describe 'profiles::elasticsearch' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::elasticsearch').with(
          'version' => '5.2.2'
        ) }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_apt__source('elastic-5.x') }

        it { is_expected.to contain_file('/data/elasticsearch').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_sysctl('vm.max_map_count').with(
          'value' => '262144'
        ) }

        it { is_expected.to contain_class('elasticsearch').with(
          'version'           => '5.2.2',
          'manage_repo'       => false,
          'api_timeout'       => 30,
          'restart_on_change' => true,
          'instances'         => {}
        ) }

        it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-5.x]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('File[/data/elasticsearch]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Sysctl[vm.max_map_count]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Class[profiles::java]') }
      end

      context "with version => 8.2.1" do
        let(:params) { {
          'version' => '8.2.1'
        } }

        it { is_expected.to contain_class('elasticsearch').with(
          'version' => '8.2.1'
        ) }

        it { is_expected.to contain_apt__source('elastic-8.x') }

        it { is_expected.to contain_class('elasticsearch').that_requires('Apt::Source[elastic-8.x]') }
      end
    end
  end
end
