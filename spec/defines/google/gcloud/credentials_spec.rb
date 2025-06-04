describe 'profiles::google::gcloud::credentials' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with title root" do
        let(:title) { 'root' }

        context 'with project_id => foo, private_key_id => 123abc, private_key => xyz789, client_id => 456def and client_email => foo@example.com' do
          let(:params) { {
            'project_id'     => 'foo',
            'private_key_id' => '123abc',
            'private_key'    => 'xyz789',
            'client_id'      => '456def',
            'client_email'   => 'foo@example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('/etc/gcloud') }

          it { is_expected.to contain_file('gcloud credentials root').with(
            'ensure' => 'file',
            'path'   => '/etc/gcloud/credentials_root.json'
          ) }

          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"project_id": "foo",?$/) }
          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"private_key_id": "123abc",?$/) }
          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"private_key": "xyz789",?$/) }
          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"client_id": "456def",?$/) }
          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"client_email": "foo@example.com",?$/) }
          it { is_expected.to contain_file('gcloud credentials root').with_content(/\s*"client_x509_cert_url": "https:\/\/www.googleapis.com\/robot\/v1\/metadata\/x509\/foo%40example.com",?$/) }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'project_id'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key_id'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'client_id'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'client_email'/) }
        end
      end

      context "with title jenkins" do
        let(:title) { 'jenkins' }

        context "with project_id => bar, private_key_id => qwertyuiop, private_key => poiuytrewq, client_id => baz and client_email => baz@example.com" do
          let(:params) { {
            'project_id'     => 'bar',
            'private_key_id' => 'qwertyuiop',
            'private_key'    => 'poiuytrewq',
            'client_id'      => 'baz',
            'client_email'   => 'baz@example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('gcloud credentials jenkins').with(
            'ensure' => 'file',
            'path'   => '/etc/gcloud/credentials_jenkins.json'
          ) }

          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"project_id": "bar",?$/) }
          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"private_key_id": "qwertyuiop",?$/) }
          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"private_key": "poiuytrewq",?$/) }
          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"client_id": "baz",?$/) }
          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"client_email": "baz@example.com",?$/) }
          it { is_expected.to contain_file('gcloud credentials jenkins').with_content(/\s*"client_x509_cert_url": "https:\/\/www.googleapis.com\/robot\/v1\/metadata\/x509\/baz%40example.com",?$/) }
        end
      end
    end
  end
end
