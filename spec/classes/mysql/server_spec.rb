require 'spec_helper'

describe 'profiles::mysql::server' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::mysql::server').with(
          'max_open_files' => 1024
        ) }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
          'unit'          => 'mysql.service',
          'filename'      => 'override.conf',
          'content'       => "[Service]\nLimitNOFILE=1024"
        ) }

        it { is_expected.to contain_class('mysql::server') }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_comes_before('Class[mysql::server]') }
        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').that_notifies('Class[mysql::server::service]') }
      end

      context "with max_open_files => 5120" do
        let(:params) { {
          'max_open_files' => 5120
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_systemd__dropin_file('mysql override.conf').with(
          'unit'          => 'mysql.service',
          'filename'      => 'override.conf',
          'content'       => "[Service]\nLimitNOFILE=5120"
        ) }
      end
    end
  end
end
