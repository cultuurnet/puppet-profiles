require 'spec_helper'

describe 'profiles::puppetdb::cli' do
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

        case facts[:os]['release']['major']
        when '14.04', '16.04'
          it { is_expected.to contain_apt__source('cultuurnet-tools') }
          it { is_expected.to contain_package('rubygem-puppetdb-cli').that_requires('Apt::Source[cultuurnet-tools]') }
        when '18.04'
          it { is_expected.to contain_apt__source('publiq-tools') }
          it { is_expected.to contain_package('rubygem-puppetdb-cli').that_requires('Apt::Source[publiq-tools]') }
        end

        it { is_expected.to contain_class('profiles::puppetdb::cli').with(
          'server_urls' => 'https://example.com:1234',
          'users'       => 'root',
          'certificate' => nil,
          'private_key' => nil
        ) }

        it { is_expected.to contain_package('rubygem-puppetdb-cli') }

        it { is_expected.to contain_profiles__puppetdb__cli__config('root').with(
          'server_urls' => 'https://example.com:1234',
          'certificate' => nil,
          'private_key' => nil
        ) }
      end

      context "with server_urls => [ https://example.com:1234, https://example.com:5678], users => [ 'root', 'jenkins'], certificate => abc123 and private_key => def456" do
        let(:params) { {
          'server_urls' => [ 'https://example.com:1234', 'https://example.com:5678'],
          'users'       => [ 'root', 'jenkins'],
          'certificate' => 'abc123',
          'private_key' => 'def456'
        } }

        it { is_expected.to contain_profiles__puppetdb__cli__config('root').with(
          'server_urls' => [ 'https://example.com:1234', 'https://example.com:5678'],
          'certificate' => 'abc123',
          'private_key' => 'def456'
        ) }

        it { is_expected.to contain_profiles__puppetdb__cli__config('jenkins').with(
          'server_urls' => [ 'https://example.com:1234', 'https://example.com:5678'],
          'certificate' => 'abc123',
          'private_key' => 'def456'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'server_urls'/) }
      end
    end
  end
end
