require 'spec_helper'

describe 'profiles::java' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java').with(
          'installed_versions' => 8,
          'distribution'       => 'jre',
          'headless'           => true,
          'default_version'    => nil
        ) }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 8,
          'distribution'    => 'jre',
          'headless'        => true
        ) }

        it { is_expected.to contain_package('openjdk-8-jre-headless') }
        it { is_expected.to contain_package('openjdk-8-jre-headless').that_comes_before('Class[profiles::java::alternatives]') }
      end

      context "with installed_versions => [8, 11], distribution => jdk and headless => false" do
        let(:params) { {
          'installed_versions' => [8, 11],
          'distribution'       => 'jdk',
          'headless'           => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openjdk-8-jdk') }
        it { is_expected.to contain_package('openjdk-11-jdk') }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 8,
          'distribution'    => 'jdk',
          'headless'        => false
        ) }

        it { is_expected.to contain_package('openjdk-8-jdk').that_comes_before('Class[profiles::java::alternatives]') }
        it { is_expected.to contain_package('openjdk-11-jdk').that_comes_before('Class[profiles::java::alternatives]') }
      end

      context "with installed_versions => [8, 11] and default_version => 11" do
        let(:params) { {
          'installed_versions' => [8, 11],
          'default_version'    => 11,
          'headless'           => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openjdk-8-jre') }
        it { is_expected.to contain_package('openjdk-11-jre') }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 11,
          'distribution'    => 'jre',
          'headless'        => false
        ) }

        it { is_expected.to contain_package('openjdk-8-jre').that_comes_before('Class[profiles::java::alternatives]') }
        it { is_expected.to contain_package('openjdk-11-jre').that_comes_before('Class[profiles::java::alternatives]') }
      end
    end
  end
end
