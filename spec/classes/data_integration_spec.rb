describe 'profiles::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::data_integration').with(
          'sling_connections'  => {},
          'gcloud_credentials' => {}
        ) }

        it { is_expected.to contain_class('profiles::sling').with(
          'connections' => {}
        ) }

        it { is_expected.not_to contain_profiles__google__gcloud__credentials('sling') }
      end

      context "with sling_connections => { my_connection => { type => gs, configuration => { bucket => mybucket, key_file => /tmp/keyfile } } } and gcloud_credentials => { project_id => foo, private_key_id => abc123, private_key => xyz789, client_id => bar and client_email => bar@example.com }" do
        let(:params) { {
          'sling_connections'  => {
                                    'my_connection' => {
                                      'type'          => 'gs',
                                      'configuration' => {
                                        'bucket'   => 'mybucket',
                                        'key_file' => '/my/keyfile'
                                      }
                                    }
                                  },
          'gcloud_credentials' => {
                                    'project_id'     => 'foo',
                                    'private_key_id' => 'abc123',
                                    'private_key'    => 'xyz789',
                                    'client_id'      => 'bar',
                                    'client_email'   => 'bar@example.com'
                                  }
        } }

        it { is_expected.to contain_class('profiles::sling').with(
          'connections' => {
                             'my_connection' => {
                               'type'          => 'gs',
                               'configuration' => {
                                 'bucket'   => 'mybucket',
                                 'key_file' => '/my/keyfile'
                               }
                             }
                           }
        ) }

        it { is_expected.to contain_profiles__google__gcloud__credentials('sling').with(
          'project_id'     => 'foo',
          'private_key_id' => 'abc123',
          'private_key'    => 'xyz789',
          'client_id'      => 'bar',
          'client_email'   => 'bar@example.com'
        ) }
      end
    end
  end
end
