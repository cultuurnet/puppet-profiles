describe 'profiles::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('update_facts').with(
        'ensure' => 'file',
        'group'  => 'root',
        'mode'   => '0755',
        'owner'  => 'root',
        'path'   => '/usr/local/bin/update_facts',
        'source' => 'puppet:///modules/profiles/deployment/update_facts'
      ) }
    end
  end
end
