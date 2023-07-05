require 'spec_helper'

describe 'profiles::logrotate' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::logrotate').with(
        ) }

        it { is_expected.to contain_class('logrotate').with(
          'ensure' => 'installed',
          'config' => {
                        'compress'      => true,
                        'delaycompress' => true,
                        'rotate'        => 10,
                        'rotate_every'  => 'week',
                        'missingok'     => true,
                        'ifempty'       => true
                      }
        ) }
      end
    end
  end
end
