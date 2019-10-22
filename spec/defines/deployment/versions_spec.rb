require 'spec_helper'

describe 'profiles::deployment::versions' do
  let(:title) { 'exampleproject' }

  context "with project => example" do
    let(:params) { {
      'project'  => 'example'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('jq').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to have_exec_resource_count(0) }

        context "with packages => foo and destination_dir => /tmp" do
          let(:params) {
            super().merge( {
              'packages'        => 'foo',
              'destination_dir' => '/tmp'
            } )
          }

          it { is_expected.to contain_exec('update versions.example file for package foo').with(
            'command'     => 'facter -pj example_version | jq \'.["example_version"]\' > /tmp/versions.example',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update versions.example.foo file for package foo').with(
            'command'     => 'facter -pj example_version.foo | jq \'.["example_version.foo"]\' > /tmp/versions.example.foo',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.not_to contain_exec('update_facts for foo package') }

          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example file for package foo]') }
          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example.foo file for package foo]') }
        end

        context "with packages => [ 'bar', 'baz'] and puppetdb_url => http://localhost:8080" do
          let(:params) {
            super().merge( {
              'packages'     => [ 'bar', 'baz'],
              'puppetdb_url' => 'http://localhost:8080'
            } )
          }

          it { is_expected.to contain_exec('update versions.example file for package bar').with(
            'command'     => 'facter -pj example_version | jq \'.["example_version"]\' > /var/www/versions.example',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update versions.example file for package baz').with(
            'command'     => 'facter -pj example_version | jq \'.["example_version"]\' > /var/www/versions.example',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update versions.example.bar file for package bar').with(
            'command'     => 'facter -pj example_version.bar | jq \'.["example_version.bar"]\' > /var/www/versions.example.bar',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update versions.example.baz file for package baz').with(
            'command'     => 'facter -pj example_version.baz | jq \'.["example_version.baz"]\' > /var/www/versions.example.baz',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update_facts for bar package').with(
            'command'     => 'update_facts -p http://localhost:8080',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_exec('update_facts for baz package').with(
            'command'     => 'update_facts -p http://localhost:8080',
            'path'        => [ '/bin', '/usr/local/bin', '/usr/bin', '/opt/puppetlabs/bin'],
            'refreshonly' => true
            )
          }

          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example file for package bar]') }
          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example file for package baz]') }
          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example.bar file for package bar]') }
          it { is_expected.to contain_package('jq').that_comes_before('Exec[update versions.example.baz file for package baz]') }

          it { is_expected.to contain_exec('update_facts for bar package').that_subscribes_to('Class[profiles::deployment]') }
          it { is_expected.to contain_exec('update_facts for baz package').that_subscribes_to('Class[profiles::deployment]') }
        end
      end
    end
  end
end
