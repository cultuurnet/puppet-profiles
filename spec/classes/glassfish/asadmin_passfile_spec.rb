require 'spec_helper'

describe 'profiles::glassfish::asadmin_passfile' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('glassfish') }
        it { is_expected.to contain_user('glassfish') }

        it { is_expected.to contain_file('asadmin_passfile').with(
          'ensure'  => 'file',
          'path'    => '/home/glassfish/asadmin.pass',
          'owner'   => 'glassfish',
          'group'   => 'glassfish',
          'mode'    => '0600'
        ) }

        it { is_expected.to contain_file('asadmin_passfile').with_content(/^AS_ADMIN_PASSWORD=adminadmin$/) }
        it { is_expected.to contain_file('asadmin_passfile').with_content(/^AS_ADMIN_MASTERPASSWORD=changeit$/) }
        it { is_expected.to contain_file('asadmin_passfile').that_requires('Group[glassfish]') }
        it { is_expected.to contain_file('asadmin_passfile').that_requires('User[glassfish]') }
      end

      context "with password => foo and master_password => bar" do
        let(:params) { {
          'password'        => 'foo',
          'master_password' => 'bar'
        } }

        it { is_expected.to contain_file('asadmin_passfile').with_content(/^AS_ADMIN_PASSWORD=foo$/) }
        it { is_expected.to contain_file('asadmin_passfile').with_content(/^AS_ADMIN_MASTERPASSWORD=bar$/) }
      end
    end
  end
end
