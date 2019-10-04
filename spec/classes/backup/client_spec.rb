require 'spec_helper'

describe 'profiles::backup::client' do
  context "with private_key => 'abcd1234'" do
    let(:params) { { 'private_key' => 'abcd1234' } }

    # include_examples 'operating system support', 'profiles::backup::client'

    on_supported_os.each do |os, facts|
      context "on #{os}" do

        case facts[:os]['release']['major']
        when '14.04'
          let (:facts) { facts }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_apt__source('cultuurnet-tools') }
          it { is_expected.to contain_profiles__apt__update('cultuurnet-tools') }

          it { is_expected.to contain_class('borgbackup').with(
            'configurations' => {}
            )
          }

          it { is_expected.to contain_class('borgbackup').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

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
      end
    end
  end

  context "without parameters" do
    let(:params) { { } }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'private_key'/) }
  end
end
