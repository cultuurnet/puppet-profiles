RSpec.shared_examples "puppetdb-cli config file structure" do |user, rootdir|
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_file(rootdir).with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet").with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl").with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl/certs").with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl/private_keys").with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl/certs/ca.pem").with(
    'ensure' => 'file',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/client-tools").with(
    'ensure' => 'directory',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("puppetdb-cli-config #{user}").with(
    'ensure' => 'file',
    'owner'  => user,
    'group'  => user,
    'path'   => "#{rootdir}/client-tools/puppetdb.conf"
  ) }
end

describe 'profiles::puppet::puppetdb::cli::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on node1.example.com with title root" do
        let(:node) { 'node1.example.com' }
        let(:trusted_facts) { { 'certname' => 'node1.example.com' } }
        let(:title) { 'root' }

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
            'server_urls'      => 'https://example.com:1234',
            'certificate_name' => nil
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/client-tools').with('ensure' => 'directory') }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/certs/node1.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/node1.example.com.pem',
            'owner'  => 'root',
            'group'  => 'root'
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/private_keys/node1.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/node1.example.com.pem',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/certs/ca.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config root').with(
            'ensure' => 'file',
            'path'   => '/root/.puppetlabs/client-tools/puppetdb.conf',
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cacert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/node1.example.com.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"key":\s*"\/root\/.puppetlabs\/puppet\/ssl\/private_keys\/node1.example.com.pem"/) }
        end

        context "with server_urls => [https://example.com:1234, https://example.com:5678] and certificate_name => abc123" do
          let(:params) { {
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => 'abc123'
          } }

          include_examples 'puppetdb-cli config file structure', 'root', '/root/.puppetlabs'

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/certs/abc123.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/abc123.pem',
            'owner'  => 'root',
            'group'  => 'root'
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/private_keys/abc123.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/abc123.pem',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/certs/ca.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234",\s*"https:\/\/example.com:5678"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cacert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/abc123.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"key":\s*"\/root\/.puppetlabs\/puppet\/ssl\/private_keys\/abc123.pem"/) }
        end

        context "without parameters" do
          let(:params) { {} }

          context "with hieradata" do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_profiles__puppet__puppetdb__cli__config('root').with(
              'server_urls'      => 'http://localhost:8081',
              'certificate_name' => nil
            ) }
          end

          context "without hieradata" do
            let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

            it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
          end
        end
      end

      context "on node2.example.com with title jenkins" do
        let(:node) { 'node2.example.com' }
        let(:trusted_facts) { { 'certname' => 'node2.example.com' } }
        let(:title) { 'jenkins' }

        context "with server_urls => [https://example.com:1234, https://example.com:5678] and certificate_name => abc123" do
          let(:params) { {
            'server_urls'      => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate_name' => '123abc'
          } }

          include_examples 'puppetdb-cli config file structure', 'jenkins', '/var/lib/jenkins/.puppetlabs'

          it { is_expected.to contain_group('jenkins') }
          it { is_expected.to contain_user('jenkins') }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/certs/123abc.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/123abc.pem',
            'owner'  => 'jenkins',
            'group'  => 'jenkins'
          ) }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/private_keys/123abc.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/123abc.pem',
            'owner'  => 'jenkins',
            'group'  => 'jenkins',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/certs/ca.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem'
          ) }

          it { is_expected.to contain_user('jenkins').that_comes_before('File[puppetdb-cli-config jenkins]') }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234",\s*"https:\/\/example.com:5678"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cacert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/123abc.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"key":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/private_keys\/123abc.pem"/) }
        end

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/certs/node2.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/node2.example.com.pem',
            'owner'  => 'jenkins',
            'group'  => 'jenkins'
          ) }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/private_keys/node2.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/node2.example.com.pem',
            'owner'  => 'jenkins',
            'group'  => 'jenkins',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_user('jenkins').that_comes_before('File[puppetdb-cli-config jenkins]') }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cacert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/node2.example.com.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"key":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/private_keys\/node2.example.com.pem"/) }
        end
      end

      context "on node3.example.com with title foobar" do
        let(:node) { 'node3.example.com' }
        let(:trusted_facts) { { 'certname' => 'node3.example.com' } }
        let(:title) { 'foobar' }

        context "with server_urls => https://foobar.example.com:8080 and certificate_name => 987zyx" do
          let(:params) { {
            'server_urls'      => 'https://foobar.example.com:8080',
            'certificate_name' => '987zyx'
          } }

          include_examples 'puppetdb-cli config file structure', 'foobar', '/home/foobar/.puppetlabs'

          it { is_expected.to_not contain_group('foobar') }
          it { is_expected.to_not contain_user('foobar') }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/certs/987zyx.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/987zyx.pem',
            'owner'  => 'foobar',
            'group'  => 'foobar',
          ) }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/private_keys/987zyx.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/987zyx.pem',
            'owner'  => 'foobar',
            'group'  => 'foobar',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"server_urls":\s*\[\s*"https:\/\/foobar.example.com:8080"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cacert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/987zyx.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"key":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/private_keys\/987zyx.pem"/) }
        end

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/certs/node3.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/node3.example.com.pem',
            'owner'  => 'foobar',
            'group'  => 'foobar'
          ) }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/private_keys/node3.example.com.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/node3.example.com.pem',
            'owner'  => 'foobar',
            'group'  => 'foobar',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cacert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/node3.example.com.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"key":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/private_keys\/node3.example.com.pem"/) }
        end
      end

      context "on node4.example.com with title www-data" do
        let(:node) { 'node4.example.com' }
        let(:trusted_facts) { { 'certname' => 'node4.example.com' } }
        let(:title) { 'www-data' }

        context "with server_urls => https://example.com:1234 and certificate_name => abc123" do
          let(:params) { {
            'server_urls'      => 'https://example.com:1234',
            'certificate_name' => '123abc'
          } }

          include_examples 'puppetdb-cli config file structure', 'www-data', '/var/www/.puppetlabs'

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('/var/www/.puppetlabs/puppet/ssl/certs/123abc.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/123abc.pem',
            'owner'  => 'www-data',
            'group'  => 'www-data'
          ) }

          it { is_expected.to contain_file('/var/www/.puppetlabs/puppet/ssl/private_keys/123abc.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/private_keys/123abc.pem',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0400'
          ) }

          it { is_expected.to contain_file('/var/www/.puppetlabs/puppet/ssl/certs/ca.pem').with(
            'source' => 'file:///etc/puppetlabs/puppet/ssl/certs/ca.pem'
          ) }

          it { is_expected.to contain_user('www-data').that_comes_before('File[puppetdb-cli-config www-data]') }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"cacert":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"cert":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/certs\/123abc.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"key":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/private_keys\/123abc.pem"/) }
        end
      end
    end
  end
end
