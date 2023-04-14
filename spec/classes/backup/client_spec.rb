require 'spec_helper'

describe 'profiles::backup::client' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with private_key => 'abcd1234'" do
        let(:params) { { 'private_key' => 'abcd1234' } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_class('borgbackup').with(
          'configurations' => {}
          )
        }

        it { is_expected.to contain_class('borgbackup').that_requires('Apt::Source[publiq-tools]') }

        it { is_expected.to contain_file('/root/.ssh').with(
          'ensure' => 'directory',
          'mode'   => '0700',
          'owner'  => 'root',
          'group'  => 'root'
          )
        }

        it { is_expected.to contain_file('/root/.ssh/backup_rsa').with(
          'ensure'  => 'file',
          'mode'    => '0400',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => 'abcd1234'
          )
        }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key'/) }
      end
    end
  end
end
