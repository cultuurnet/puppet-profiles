describe 'profiles::gcsfuse' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::gcsfuse').with(
          'credentials_source' => nil
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_package('gcsfuse') }

        it { is_expected.to contain_file('/etc/gcsfuse').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_package('gcsfuse').that_requires('Apt::Source[publiq-tools]') }
      end

      context 'with credentials_source => /foo/bar.json' do
        let(:params) { {
          'credentials_source' => '/foo/bar.json'
        } }

        it { is_expected.to contain_package('gcsfuse') }

        it { is_expected.to contain_file('/etc/gcsfuse').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_file('gcsfuse-credentials').with(
          'ensure' => 'file',
          'path'   => '/etc/gcsfuse/gcs_credentials.json',
          'source' => '/foo/bar.json'
        ) }

        it { is_expected.to contain_file('gcsfuse-credentials').that_requires('File[/etc/gcsfuse]') }
      end
    end
  end
end
