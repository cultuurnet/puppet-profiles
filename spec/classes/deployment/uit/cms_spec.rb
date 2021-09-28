require 'spec_helper'

describe 'profiles::deployment::uit::cms' do
  context "with settings_source => /foo, hostnames_source => /abc and drush_config_source => /bar" do
    let(:params) { {
      'settings_source'     => '/foo',
      'hostnames_source'    => '/abc',
      'drush_config_source' => '/bar'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('publiq-uit') }

        it { is_expected.to contain_file('hostnames.txt').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-cms/hostnames.txt',
          'source' => '/abc'
        ) }
      end
    end
  end

  context "with settings_source => /baz, drush_config_source => /zzz, version => 1.2.3, database_version => 4.5.6, files_version => 4 and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'settings_source'     => '/baz',
      'hostnames_source'    => '/xyz',
      'drush_config_source' => '/zzz',
      'version'             => '1.2.3',
      'database_version'    => '4.5.6',
      'files_version'       => '4',
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_profiles__deployment__versions('profiles::deployment::uit::cms').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }

        it { is_expected.to contain_file('hostnames.txt').with(
          'ensure' => 'file',
          'path'   => '/var/www/uit-cms/hostnames.txt',
          'source' => '/xyz'
        ) }
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'settings_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'hostnames_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'drush_config_source'/) }
      end
    end
  end
end
