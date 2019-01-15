require 'spec_helper'

describe 'profiles::rabbitmq' do
  include_examples 'operating system support', 'profiles::rabbitmq'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('rabbitmq') }

      it { is_expected.to contain_class('rabbitmq').with(
        'manage_repos'      => false,
        'delete_guest_user' => true
        )
      }
    end
  end
end
