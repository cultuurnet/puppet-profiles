require 'spec_helper'

describe 'profiles::java::alternatives' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('profiles::java::alternatives') }

        it { is_expected.to_not contain_alternatives('java') }
        it { is_expected.to_not contain_shellvar('JAVA_HOME') }
      end

      context "with default_version => 8" do
        let(:params) { { 'default_version' => 8 } }

        it { is_expected.to contain_shellvar('JAVA_HOME').with(
          'ensure' => 'present',
          'target' => '/etc/environment',
          'value'  => '/usr/lib/jvm/java-8-oracle'
        ) }

        it { is_expected.to contain_alternatives('java').with(
          'path' => '/usr/lib/jvm/java-8-oracle/jre/bin/java'
          )
        }
      end

      context "with default_version => 11" do
        let(:params) { { 'default_version' => 11 } }

        it { is_expected.to contain_shellvar('JAVA_HOME').with(
          'ensure' => 'present',
          'target' => '/etc/environment',
          'value'  => '/usr/lib/jvm/jdk-11.0.12'
        ) }

        it { is_expected.to contain_alternatives('java').with(
          'path' => '/usr/lib/jvm/jdk-11.0.12/bin/java'
          )
        }
      end
    end
  end
end
