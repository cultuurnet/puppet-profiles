require 'spec_helper'

describe 'profiles::logrotate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_logrotate__conf('/etc/logrotate.conf').with(
          'compress'      => true,
          'delaycompress' => true,
          'rotate'        => 10,
          'rotate_every'  => 'week',
          'missingok'     => true,
          'ifempty'       => true,
          'su'            => true,
          'su_user'       => 'root',
          'su_group'      => 'adm'
        ) }
      end
    end
  end
end
