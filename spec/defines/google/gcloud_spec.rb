describe 'profiles::google::gcloud' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title root" do
        let(:title) { 'root' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('google-cloud-cli') }
          it { is_expected.to contain_file('/etc/gcloud') }

          it { is_expected.to contain_package('google-cloud-cli').that_requires('Apt::Source[publiq-tools]') }
        end

        context "with credentials_source => /tmp/credentials.json" do
          let(:params) { {
            'credentials_source' => '/tmp/credentials.json'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('google-cloud-cli') }
          it { is_expected.to contain_file('/etc/gcloud') }

          it { is_expected.to contain_file('gcloud credentials root').with(
            'ensure' => 'file',
            'path'   => '/etc/gcloud/credentials_root.json'
          ) }

          it { is_expected.not_to contain_exec('gcloud auth login for user root') }

          it { is_expected.to contain_file('gcloud credentials root').that_requires('File[/etc/gcloud]') }
        end
      end

      context "with title jenkins" do
        let(:title) { 'jenkins' }

        context "with credentials_source => /tmp/bla.json and project => abc123" do
          let(:params) { {
            'credentials_source' => '/tmp/bla.json',
            'project'            => 'abc123'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('google-cloud-cli') }
          it { is_expected.to contain_file('/etc/gcloud') }

          it { is_expected.to contain_file('gcloud credentials jenkins').with(
            'ensure' => 'file',
            'path'   => '/etc/gcloud/credentials_jenkins.json'
          ) }

          it { is_expected.to contain_exec('gcloud auth login for user jenkins').with(
            'command'     => '/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_jenkins.json --project=abc123',
            'refreshonly' => true,
            'user'        => 'jenkins'
          ) }

          it { is_expected.to contain_file('gcloud credentials jenkins').that_requires('File[/etc/gcloud]') }
          it { is_expected.to contain_exec('gcloud auth login for user jenkins').that_requires('Package[google-cloud-cli]') }
          it { is_expected.to contain_exec('gcloud auth login for user jenkins').that_requires('File[gcloud credentials jenkins]') }
        end
      end
    end
  end
end
