require 'spec_helper'

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
    'group'  => user,
    'source' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem'
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl/certs/puppetdb-cli.crt").with(
    'ensure' => 'file',
    'owner'  => user,
    'group'  => user
  ) }

  it { is_expected.to contain_file("#{rootdir}/puppet/ssl/private_keys/puppetdb-cli.key").with(
    'ensure' => 'file',
    'owner'  => user,
    'group'  => user,
    'mode'   => '0400'
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

describe 'profiles::puppetdb::cli::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on node1.example.com with title root" do
        let(:node) { 'node1.example.com' }
        let(:title) { 'root' }

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__puppetdb__cli__config('root').with(
            'server_urls' => 'https://example.com:1234',
            'certificate' => nil,
            'private_key' => nil
          ) }

          it { is_expected.to_not contain_file('/etc/puppetlabs') }

          it { is_expected.to contain_file('/etc/puppetlabs/client-tools').with('ensure' => 'directory') }

          it { is_expected.to contain_file('puppetdb-cli-config root').with(
            'ensure' => 'file',
            'path'   => '/etc/puppetlabs/client-tools/puppetdb.conf',
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cacert":\s*"\/etc\/puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cert":\s*"\/etc\/puppetlabs\/puppet\/ssl\/certs\/node1.example.com.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"key":\s*"\/etc\/puppetlabs\/puppet\/ssl\/private_keys\/node1.example.com.pem"/) }
        end

        context "with server_urls => [https://example.com:1234, https://example.com:5678], certificate => abc123 and private_key => def456" do
          let(:params) { {
            'server_urls' => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate' => 'abc123',
            'private_key' => 'def456'
          } }

          include_examples 'puppetdb-cli config file structure', 'root', '/root/.puppetlabs'

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/certs/puppetdb-cli.crt').with(
            'content' => 'abc123'
          ) }

          it { is_expected.to contain_file('/root/.puppetlabs/puppet/ssl/private_keys/puppetdb-cli.key').with(
            'content' => 'def456'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234",\s*"https:\/\/example.com:5678"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cacert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"cert":\s*"\/root\/.puppetlabs\/puppet\/ssl\/certs\/puppetdb-cli.crt"/) }
          it { is_expected.to contain_file('puppetdb-cli-config root').with_content(/"key":\s*"\/root\/.puppetlabs\/puppet\/ssl\/private_keys\/puppetdb-cli.key"/) }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
        end
      end

      context "on node2.example.com with title jenkins" do
        let(:node) { 'node2.example.com' }
        let(:title) { 'jenkins' }

        context "with server_urls => [https://example.com:1234, https://example.com:5678], certificate => abc123 and private_key => def456" do
          let(:params) { {
            'server_urls' => ['https://example.com:1234', 'https://example.com:5678'],
            'certificate' => '123abc',
            'private_key' => '456def'
          } }

          include_examples 'puppetdb-cli config file structure', 'jenkins', '/var/lib/jenkins/.puppetlabs'

          it { is_expected.to contain_group('jenkins') }
          it { is_expected.to contain_user('jenkins') }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/certs/puppetdb-cli.crt').with(
            'content' => '123abc'
          ) }

          it { is_expected.to contain_file('/var/lib/jenkins/.puppetlabs/puppet/ssl/private_keys/puppetdb-cli.key').with(
            'content' => '456def'
          ) }

          it { is_expected.to contain_user('jenkins').that_comes_before('File[puppetdb-cli-config jenkins]') }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234",\s*"https:\/\/example.com:5678"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cacert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"cert":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/certs\/puppetdb-cli.crt"/) }
          it { is_expected.to contain_file('puppetdb-cli-config jenkins').with_content(/"key":\s*"\/var\/lib\/jenkins\/.puppetlabs\/puppet\/ssl\/private_keys\/puppetdb-cli.key"/) }
        end

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameters 'certificate' and 'private_key'/) }
        end
      end

      context "on node3.example.com with title foobar" do
        let(:node) { 'node3.example.com' }
        let(:title) { 'foobar' }

        context "with server_urls => https://foobar.example.com:8080, certificate => 987zyx and private_key => xyz789" do
          let(:params) { {
            'server_urls' => 'https://foobar.example.com:8080',
            'certificate' => '987zyx',
            'private_key' => 'xyz789'
          } }

          include_examples 'puppetdb-cli config file structure', 'foobar', '/home/foobar/.puppetlabs'

          it { is_expected.to_not contain_group('foobar') }
          it { is_expected.to_not contain_user('foobar') }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/certs/puppetdb-cli.crt').with(
            'content' => '987zyx'
          ) }

          it { is_expected.to contain_file('/home/foobar/.puppetlabs/puppet/ssl/private_keys/puppetdb-cli.key').with(
            'content' => 'xyz789'
          ) }

          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"server_urls":\s*\[\s*"https:\/\/foobar.example.com:8080"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cacert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"cert":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/certs\/puppetdb-cli.crt"/) }
          it { is_expected.to contain_file('puppetdb-cli-config foobar').with_content(/"key":\s*"\/home\/foobar\/.puppetlabs\/puppet\/ssl\/private_keys\/puppetdb-cli.key"/) }
        end

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameters 'certificate' and 'private_key'/) }
        end
      end

      context "on node4.example.com with title www-data" do
        let(:node) { 'node4.example.com' }
        let(:title) { 'www-data' }

        context "with server_urls => https://example.com:1234, certificate => abc123 and private_key => def456" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234',
            'certificate' => '123abc',
            'private_key' => '456def'
          } }

          include_examples 'puppetdb-cli config file structure', 'www-data', '/var/www/.puppetlabs'

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('/var/www/.puppetlabs/puppet/ssl/certs/puppetdb-cli.crt').with(
            'content' => '123abc'
          ) }

          it { is_expected.to contain_file('/var/www/.puppetlabs/puppet/ssl/private_keys/puppetdb-cli.key').with(
            'content' => '456def'
          ) }

          it { is_expected.to contain_user('www-data').that_comes_before('File[puppetdb-cli-config www-data]') }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"server_urls":\s*\[\s*"https:\/\/example.com:1234"\s*\]/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"cacert":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/certs\/ca.pem"/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"cert":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/certs\/puppetdb-cli.crt"/) }
          it { is_expected.to contain_file('puppetdb-cli-config www-data').with_content(/"key":\s*"\/var\/www\/.puppetlabs\/puppet\/ssl\/private_keys\/puppetdb-cli.key"/) }
        end

        context "with server_urls => https://example.com:1234" do
          let(:params) { {
            'server_urls' => 'https://example.com:1234'
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameters 'certificate' and 'private_key'/) }
        end
      end
    end
  end
end
