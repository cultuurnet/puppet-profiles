require 'spec_helper'

describe 'profiles::java8' do
  include_examples 'operating system support', 'profiles::java8'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_apt__source('cultuurnet-tools') }

      it { is_expected.to contain_file('/var/cache').with(
        'ensure' => 'directory'
        )
      }

      it { is_expected.to contain_file('/var/cache/oracle-jdk8-installer').with(
        'ensure' => 'directory'
        )
      }

      it { is_expected.to contain_wget__fetch('jdk-8u151-linux-x64.tar.gz').with(
        'destination' => '/var/cache/oracle-jdk8-installer/jdk-8u151-linux-x64.tar.gz',
        'source'      => 'https://s3-eu-west-1.amazonaws.com/udb3-vagrant/jdk-8u151-linux-x64.tar.gz'
        )
      }

      it { is_expected.to contain_wget__fetch('jdk-8u151-linux-x64.tar.gz').that_comes_before('Class[java8]') }
      it { is_expected.to contain_wget__fetch('jdk-8u151-linux-x64.tar.gz').that_requires('File[/var/cache/oracle-jdk8-installer]') }

      it { is_expected.to contain_class('java8').with(
        'installer_version' => '8u151-1~webupd8~0',
        'manage_repos'      => false
        )
      }

      it { is_expected.to contain_class('java8').that_requires('Apt::Source[cultuurnet-tools]') }
    end
  end
end
