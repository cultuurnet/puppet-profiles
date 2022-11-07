require 'spec_helper'

describe 'profiles::elasticdump' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::nodejs') }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_package('elasticdump') }

        it { is_expected.to contain_package('elasticdump').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('elasticdump').that_requires('Class[profiles::nodejs]') }

        it { is_expected.to contain_alternative_entry('/opt/elasticdump/node_modules/elasticdump/bin/elasticdump').with(
          'ensure'  => 'present',
          'altname' => 'elasticdump',
          'priority' => 10,
          'altlink'  => '/usr/bin/elasticdump'
        ) }
      end
    end
  end
end
