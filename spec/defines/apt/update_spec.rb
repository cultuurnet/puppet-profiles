require 'spec_helper'

describe 'profiles::apt::update' do
  let(:title) { 'foobar' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let (:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_exec('apt-get update foobar').with(
        'command' => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/foobar.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
        'path'    => [ '/usr/local/bin', '/usr/bin']
        )
      }

      context "with title => guineapig" do
        let(:title) { 'guineapig' }

        it { is_expected.to contain_exec('apt-get update guineapig').with(
          'command' => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/guineapig.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
          'path'    => [ '/usr/local/bin', '/usr/bin']
          )
        }
      end
    end
  end
end
