require 'spec_helper'

describe 'profiles::puppet::puppetserver::puppetdb' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
   context "on #{os}" do
      let(:facts) { facts }

      context "with url => https://foo.example.com:8081" do
        let(:params) { {
          'url' => 'https://foo.example.com:8081'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_ini_subsetting('puppetserver reports').with(
          'ensure'               => 'present',
          'path'                 => '/etc/puppetlabs/puppet/puppet.conf',
          'section'              => 'main',
          'setting'              => 'reports',
          'subsetting'           => 'puppetdb',
          'subsetting_separator' => ','
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
      end
    end
  end
end
