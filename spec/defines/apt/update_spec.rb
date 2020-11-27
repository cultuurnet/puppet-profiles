require 'spec_helper'

describe 'profiles::apt::update' do
  let(:title) { 'foobar' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      context "with the correct virtual apt::source resource" do
        let (:pre_condition) { '@apt::source { "foobar": location => "test" }' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('foobar') }

        it { is_expected.to contain_exec('apt-get update foobar').with(
          'command'   => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/foobar.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
          'path'      => [ '/usr/local/bin', '/usr/bin'],
          'logoutput' => 'on_failure'
          )
        }

        it { is_expected.to contain_exec('apt-get update foobar').that_requires('Apt::Source[foobar]') }
      end

      context "with title => guineapig and the correct virtual apt::source resource" do
        let(:title) { 'guineapig' }
        let (:pre_condition) { '@apt::source { "guineapig": location => "test" }' }

        it { is_expected.to contain_apt__source('guineapig') }

        it { is_expected.to contain_exec('apt-get update guineapig').with(
          'command'   => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/guineapig.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
          'path'      => [ '/usr/local/bin', '/usr/bin'],
          'logoutput' => 'on_failure'
          )
        }

        it { is_expected.to contain_exec('apt-get update guineapig').that_requires('Apt::Source[guineapig]') }
      end
    end
  end
end
