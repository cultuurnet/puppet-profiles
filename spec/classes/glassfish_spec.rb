require 'spec_helper'

RSpec.shared_examples "glassfish" do |flavor|
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_apt__source('cultuurnet-tools') }

  it { is_expected.to contain_class('profiles::java8') }

  it { is_expected.to contain_class('glassfish').with(
    'install_method'      => 'package',
    'package_prefix'      => flavor,
    'create_service'      => false,
    'enable_secure_admin' => false,
    'manage_java'         => false,
    'parent_dir'          => '/opt',
    'install_dir'         => flavor,
    )
  }

  it { is_expected.to contain_class('glassfish').that_requires('Class[profiles::java8]') }

  it { is_expected.to contain_package('mysql-connector-java').with(
    'ensure' => 'latest'
    )
  }

  it { is_expected.to contain_file('mysql-connector-java').with(
    'ensure' => 'link',
    'path'   => "/opt/#{flavor}/glassfish/lib/mysql-connector-java.jar",
    'target' => '/opt/mysql-connector-java/mysql-connector-java.jar'
    )
  }

  it { is_expected.to contain_file('mysql-connector-java').that_subscribes_to('Package[mysql-connector-java]') }

  it { is_expected.to contain_file('mysql-connector-java').that_requires('Class[glassfish]') }
end

describe 'profiles::glassfish' do
  include_examples 'operating system support', 'profiles::glassfish'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        include_examples 'glassfish', 'payara'
      end

      context "with flavor => 'payara'" do
        let(:params) { { 'flavor' => 'payara' } }

        include_examples 'glassfish', 'payara'
      end

      context "with flavor => 'glassfish'" do
        let(:params) { { 'flavor' => 'glassfish' } }

        include_examples 'glassfish', 'glassfish'
      end
    end
  end
end
