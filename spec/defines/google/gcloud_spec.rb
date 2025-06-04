describe 'profiles::google::gcloud' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title root" do
        let(:title) { 'root' }

        context "with credentials => { project_id => foo, private_key_id => abc123, private_key => xyz789, client_id => bar and client_email => bar@example.com }" do
          let(:params) { {
            'credentials' => {
                               'project_id'     => 'foo',
                               'private_key_id' => 'abc123',
                               'private_key'    => 'xyz789',
                               'client_id'      => 'bar',
                               'client_email'   => 'bar@example.com'
                             }
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('google-cloud-cli') }

          it { is_expected.to contain_profiles__google__gcloud__credentials('root').with(
            'project_id'     => 'foo',
            'private_key_id' => 'abc123',
            'private_key'    => 'xyz789',
            'client_id'      => 'bar',
            'client_email'   => 'bar@example.com'
          ) }

          it { is_expected.to contain_exec('gcloud auth login for user root').with(
            'command'     => '/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_root.json --project=foo',
            'refreshonly' => true,
            'user'        => 'root'
          ) }

          it { is_expected.to contain_exec('gcloud auth login for user root').that_subscribes_to('Package[google-cloud-cli]') }
          it { is_expected.to contain_exec('gcloud auth login for user root').that_subscribes_to('Profiles::Google::Gcloud::Credentials[root]') }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'credentials'/) }
        end
      end

      context "with title jenkins" do
        let(:title) { 'jenkins' }

        context "with credentials => { project_id => baz, private_key_id => id, private_key => 1234, client_id => quux and client_email => quux@example.com }" do
          let(:params) { {
            'credentials' => {
                               'project_id'     => 'baz',
                               'private_key_id' => 'id',
                               'private_key'    => '1234',
                               'client_id'      => 'quux',
                               'client_email'   => 'quux@example.com'
                             }
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__google__gcloud__credentials('jenkins').with(
            'project_id'     => 'baz',
            'private_key_id' => 'id',
            'private_key'    => '1234',
            'client_id'      => 'quux',
            'client_email'   => 'quux@example.com'
          ) }

          it { is_expected.to contain_exec('gcloud auth login for user jenkins').with(
            'command'     => '/usr/bin/gcloud auth login --cred-file=/etc/gcloud/credentials_jenkins.json --project=baz',
            'refreshonly' => true,
            'user'        => 'jenkins'
          ) }

          it { is_expected.to contain_exec('gcloud auth login for user jenkins').that_subscribes_to('Package[google-cloud-cli]') }
          it { is_expected.to contain_exec('gcloud auth login for user jenkins').that_subscribes_to('Profiles::Google::Gcloud::Credentials[jenkins]') }
        end
      end
    end
  end
end
