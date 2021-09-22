require 'spec_helper'

describe 'profiles::udb3::websockets' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with config_source => /tmp/config.json" do
        let (:params) { {
          'config_source' => '/tmp/config.json'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

        it { is_expected.to contain_class('websockets::udb3').with(
          'package_version' => 'latest',
          'config_source'   => '/tmp/config.json'
        ) }

        it { is_expected.to contain_class('websockets::udb3').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }
      end

      context "with config_source => /tmp/bla.json and version => '1.2.3'" do
        let (:params) { {
          'config_source' => '/tmp/bla.json',
          'version'       => '1.2.3'
        } }

        it { is_expected.to contain_class('websockets::udb3').with(
          'package_version' => '1.2.3',
          'config_source'   => '/tmp/bla.json'
        ) }
      end

      context "without parameters" do
        let (:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
      end
    end
  end
end
