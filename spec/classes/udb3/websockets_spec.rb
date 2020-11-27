require 'spec_helper'

describe 'profiles::udb3::websockets' do
  context "with config_source => /tmp/config.json" do
    let (:params) { {
      'config_source' => '/tmp/config.json'
    } }

    include_examples 'operating system support', 'profiles::udb3::websockets'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

        it { is_expected.to contain_class('websockets::udb3').with(
          'config_source' => '/tmp/config.json'
        ) }

        it { is_expected.to contain_class('websockets::udb3').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }
      end
    end
  end

  context "without parameters" do
    let (:params) { { } }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
  end
end
