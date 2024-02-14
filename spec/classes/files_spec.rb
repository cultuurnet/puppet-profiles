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
          'group'  => 'www-data'
        ) }

        it { is_expected.to contain_file('/var/www').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('/var/www').that_requires('User[www-data]') }
      end
    end
  end
end
