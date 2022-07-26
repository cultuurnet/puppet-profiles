require 'spec_helper'

describe 'profiles::apache' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_group('www-data') }
      it { is_expected.to contain_user('www-data') }

      it { is_expected.to contain_class('apache').with(
        'mpm_module'   => 'prefork',
        'manage_group' => false,
        'manage_user'  => false
      ) }

      it { is_expected.to contain_group('www-data').that_comes_before('Class[apache]') }
      it { is_expected.to contain_user('www-data').that_comes_before('Class[apache]') }
    end
  end
end
