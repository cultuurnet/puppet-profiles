require 'spec_helper'

describe 'profiles::elasticsearch' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java8') }

        it { is_expected.to contain_profiles__apt__update('elasticsearch') }

        it { is_expected.to contain_file('/data/elasticsearch').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_sysctl('vm.max_map_count').with(
          'value' => '262144'
        ) }

        it { is_expected.to contain_class('elasticsearch') }

        it { is_expected.to contain_class('elasticsearch').that_requires('Profiles::Apt::Update[elasticsearch]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('File[/data/elasticsearch]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Sysctl[vm.max_map_count]') }
        it { is_expected.to contain_class('elasticsearch').that_requires('Class[profiles::java8]') }
      end
    end
  end
end
