require 'spec_helper'

describe 'profiles::jenkins::controller::service' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_service('jenkins').with(
        'ensure'    => 'running',
        'hasstatus' => true,
        'enable'    => true
      ) }
    end
  end
end
