require 'spec_helper'

describe 'profiles::certificates::update' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_exec('Update CA certificates').with(
        'command'     => 'update-ca-certificates',
        'path'        => [ '/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
        'refreshonly' => true
      ) }
    end
  end
end
