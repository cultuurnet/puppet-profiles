require 'spec_helper'

describe 'profiles::jenkins::buildtools' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_package('git').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('jq').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('jtm').with( {'ensure' => 'present'}) }

      it { is_expected.to contain_class('profiles::ruby').with( { 'with_dev' => true }) }
    end
  end
end
