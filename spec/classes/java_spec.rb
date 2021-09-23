require 'spec_helper'

describe 'profiles::java' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with installed_versions => 8 and default_version => 8" do
        let(:params) { {
          'installed_versions' => 8,
          'default_version'    => 8
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java::java8') }
        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 8
        )}

        it { is_expected.to contain_class('profiles::java::java8').that_comes_before('Class[profiles::java::alternatives]') }
      end

      context "with installed_versions => [ 8, 11] and default_version => 11" do
        let(:params) { {
          'installed_versions' => [ 8, 11],
          'default_version'    => 11
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java::java8') }
        it { is_expected.to contain_class('profiles::java::java11') }
        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 11
        )}

        it { is_expected.to contain_class('profiles::java::java8').that_comes_before('Class[profiles::java::alternatives]') }
        it { is_expected.to contain_class('profiles::java::java11').that_comes_before('Class[profiles::java::alternatives]') }
      end

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java::java8') }
        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => nil
        )}

        it { is_expected.to contain_class('profiles::java::java8').that_comes_before('Class[profiles::java::alternatives]') }
      end
    end
  end
end
