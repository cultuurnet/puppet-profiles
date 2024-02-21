describe 'profiles::puppet::puppetdb::cli' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on node1.example.com with server_urls => https://example.com:1234" do
        let(:node) { 'node1.example.com' }
        let(:params) { {
          'server_urls' => 'https://example.com:1234'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_package('rubygem-puppetdb-cli').that_requires('Apt::Source[publiq-tools]') }

        it { is_expected.to contain_class('profiles::puppet::puppetdb::cli').with(
          'server_urls'    => 'https://example.com:1234',
          'users'          => 'root',
          'certificate'    => nil,
          'private_key'    => nil,
          'ca_certificate' => nil
        ) }

        it { is_expected.to contain_package('rubygem-puppetdb-cli') }

        it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
          'server_urls'    => 'https://example.com:1234',
          'certificate'    => nil,
          'private_key'    => nil,
          'ca_certificate' => nil
        ) }
      end

      context "with server_urls => [ https://example.com:1234, https://example.com:5678], users => [ 'root', 'jenkins'], certificate => abc123, private_key => def456 and ca_certificate => 321cba" do
        let(:params) { {
          'server_urls'    => [ 'https://example.com:1234', 'https://example.com:5678'],
          'users'          => [ 'root', 'jenkins'],
          'certificate'    => 'abc123',
          'private_key'    => 'def456',
          'ca_certificate' => '321cba'
        } }

        it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
          'server_urls'    => [ 'https://example.com:1234', 'https://example.com:5678'],
          'certificate'    => 'abc123',
          'private_key'    => 'def456',
          'ca_certificate' => '321cba'
        ) }

        it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('jenkins').with(
          'server_urls'    => [ 'https://example.com:1234', 'https://example.com:5678'],
          'certificate'    => 'abc123',
          'private_key'    => 'def456',
          'ca_certificate' => '321cba'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
      end
    end
  end
end
