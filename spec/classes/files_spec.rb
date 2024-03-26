describe 'profiles::files' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'File <| |>',
          'Group <| |>',
          'User <| |>'
        ] }

        it { is_expected.to contain_file('/var/www').with(
          'ensure' => 'directory',
          'owner'  => 'www-data',
          'group'  => 'www-data',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/data/backup').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/var/www').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('/var/www').that_requires('User[www-data]') }
        it { is_expected.to contain_file('/data/backup').that_requires('File[/data]') }
      end
    end
  end
end
