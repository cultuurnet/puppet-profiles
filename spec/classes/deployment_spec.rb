require 'spec_helper'

describe 'profiles::deployment' do

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_file('update_facts').with(
    'ensure' => 'file',
    'group'  => 'root',
    'mode'   => '0755',
    'owner'  => 'root',
    'path'   => '/usr/local/bin/update_facts',
    'source' => 'puppet:///modules/profiles/deployment/update_facts'
    )
  }
end
