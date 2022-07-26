require 'spec_helper'

describe 'profiles::publiq::versions' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with puppetdb_url => http://localhost:8000, certificate => 'abc123' and private_key => 'def456'" do
        let(:params) { {
          'puppetdb_url' => 'http://localhost:8000',
          'certificate'  => 'abc123',
          'private_key'  => 'def456'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::versions').with(
          'deployment'      => true,
          'service_address' => '127.0.0.1',
          'service_port'    => '3000',
          'puppetdb_url'    => 'http://localhost:8000',
          'certificate'     => 'abc123',
          'private_key'     => 'def456'
        ) }

        it { is_expected.to contain_group('www-data') }
        it { is_expected.to contain_user('www-data') }

        it { is_expected.to contain_class('profiles::ruby') }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
          'service_address' => '127.0.0.1',
          'service_port'    => '3000',
          'puppetdb_url'    => 'http://localhost:8000'
        ) }

        it { is_expected.to contain_profiles__puppetdb__cli__config('www-data').with(
          'server_urls' => 'http://localhost:8000',
          'certificate' => 'abc123',
          'private_key' => 'def456'
        ) }

        it { is_expected.to contain_profiles__puppetdb__cli__config('www-data').that_notifies('Class[profiles::publiq::versions::service]') }
        it { is_expected.to contain_profiles__puppetdb__cli__config('www-data').that_requires('Group[www-data]') }
        it { is_expected.to contain_profiles__puppetdb__cli__config('www-data').that_requires('User[www-data]') }

        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Group[www-data]') }
        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('User[www-data]') }
        it { is_expected.to contain_class('profiles::publiq::versions::deployment').that_requires('Class[profiles::ruby]') }

        context "with service_address => 0.0.0.0 and service_port => 5000" do
          let(:params)  { super().merge(
            {
              'service_address' => '0.0.0.0',
              'service_port'    => 5000
            }
          ) }

          it { is_expected.to contain_class('profiles::publiq::versions::deployment').with(
            'service_address' => '0.0.0.0',
            'service_port'    => '5000',
            'puppetdb_url'    => 'http://localhost:8000'
          ) }
        end
      end

      context "with deployment => false, certificate => xyz789, private_key => pqr567 and puppetdb_url => http://example.com:8000" do
        let(:params) { {
          'deployment'   => false,
          'certificate'  => 'xyz789',
          'private_key'  => 'pqr567',
          'puppetdb_url' => 'http://example.com:8000'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::ruby') }
        it { is_expected.to_not contain_class('profiles::publiq::versions::deployment') }

        it { is_expected.to contain_profiles__puppetdb__cli__config('www-data').with(
          'server_urls' => 'http://example.com:8000',
          'certificate' => 'xyz789',
          'private_key' => 'pqr567'
        ) }

        it { is_expected.to_not contain_profiles__puppetdb__cli__config('www-data').that_notifies('Class[profiles::publiq::versions::service]') }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'puppetdb_url'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key'/) }
      end
    end
  end
end
