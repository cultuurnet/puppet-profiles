require 'spec_helper'

describe 'profiles::php' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node aaa.example.com' do
        let(:node) { 'aaa.example.com' }

        context 'without parameters' do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::php').with(
            'version'                  => '7.4',
            'extensions'               => {},
            'settings'                 => {},
            'composer_default_version' => nil,
            'newrelic_agent'           => false,
            'newrelic_app_name'        => 'aaa.example.com',
            'newrelic_license_key'     => nil
          ) }

          it { is_expected.to contain_apt__source('php') }
          it { is_expected.not_to contain_apt__source('publiq-tools') }

          it { is_expected.to contain_class('php::globals').with(
            'php_version' => '7.4',
            'config_root' => '/etc/php/7.4'
          ) }

          it { is_expected.to contain_class('php').with(
            'manage_repos' => false,
            'composer'     => false,
            'dev'          => false,
            'pear'         => false,
            'fpm'          => true,
            'settings'     => {},
            'extensions'   => {
                                'bcmath'   => {},
                                'curl'     => {},
                                'gd'       => {},
                                'intl'     => {},
                                'mbstring' => {},
                                'opcache'  => {},
                                'readline' => {},
                                'tidy'     => {},
                                'xml'      => {},
                                'zip'      => {}
                              }
          ) }

          it { is_expected.to contain_package('composer').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.not_to contain_package('composer1').with(
            'ensure' => 'present'
          ) }

          it { is_expected.not_to contain_package('composer2').with(
            'ensure' => 'present'
          ) }

          it { is_expected.not_to contain_alternatives('composer').with(
            'path' => '/usr/bin/composer2'
          ) }

          it { is_expected.not_to contain_package('git').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_class('php::globals').that_requires('Apt::Source[php]') }
          it { is_expected.to contain_class('php').that_requires('Class[php::globals]') }
        end

        context 'with version => 8.0, extensions => { mbstring => {}, mysql => { so_name => mysqlnd }, mongodb => {} }, settings => { PHP/upload_max_filesize => 22M, PHP/post_max_size => 24M } and composer_default_version => 2' do
          let(:params) { {
            'version'                  => '8.0',
            'extensions'               => {
                                            'mbstring' => {},
                                            'mysql'    => { 'so_name' => 'mysqlnd' },
                                            'mongodb'  => {}
                                          },
            'settings'                 => {
                                            'PHP/upload_max_filesize' => '22M',
                                            'PHP/post_max_size'       => '24M'
                                          },
            'composer_default_version' => 2
          } }

          it { is_expected.to contain_class('php::globals').with(
            'php_version' => '8.0',
            'config_root' => '/etc/php/8.0'
          ) }

          it { is_expected.to contain_class('php').with(
            'manage_repos' => false,
            'composer'     => false,
            'dev'          => false,
            'pear'         => false,
            'fpm'          => true,
            'settings'     => {
                                'PHP/upload_max_filesize' => '22M',
                                'PHP/post_max_size'       => '24M'
                              },
            'extensions'   => {
                                'bcmath'   => {},
                                'curl'     => {},
                                'gd'       => {},
                                'intl'     => {},
                                'mbstring' => {},
                                'mongodb'  => {},
                                'mysql'    => { 'so_name' => 'mysqlnd' },
                                'opcache'  => {},
                                'readline' => {},
                                'tidy'     => {},
                                'xml'      => {},
                                'zip'      => {}
                              }
          ) }

          it { is_expected.to contain_apt__source('publiq-tools') }

          it { is_expected.to contain_package('composer1').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_package('composer2').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_alternatives('composer').with(
            'path' => '/usr/bin/composer2'
          ) }

          it { is_expected.to contain_package('composer1').that_requires('Class[php]') }
          it { is_expected.to contain_package('composer2').that_requires('Class[php]') }
          it { is_expected.to contain_alternatives('composer').that_requires(['Package[composer1]', 'Package[composer2]']) }
        end
      end

      context 'on node bbb.example.com' do
        let(:node) { 'bbb.example.com' }

        context 'with composer_default_version => 1, newrelic_agent => true' do
          let(:params) { {
            'composer_default_version' => 1,
            'newrelic_agent'           => true
          } }

          it { is_expected.to contain_class('profiles::php').with(
            'newrelic_app_name'        => 'bbb.example.com'
          ) }

          it { is_expected.to contain_apt__source('publiq-tools') }

          it { is_expected.to contain_package('composer1').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_package('composer2').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_alternatives('composer').with(
            'path' => '/usr/bin/composer1'
          ) }
        end
      end
    end
  end
end
