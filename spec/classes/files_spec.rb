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

        it { is_expected.to contain_file('/etc/gcloud').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/var/www').that_requires('Group[www-data]') }
        it { is_expected.to contain_file('/var/www').that_requires('User[www-data]') }
        it { is_expected.to contain_file('/data/backup').that_requires('File[/data]') }
        it { is_expected.to contain_file('/etc/puppetlabs/facter').that_requires('File[/etc/puppetlabs]') }
        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').that_requires('File[/etc/puppetlabs/facter]') }
      end

      context "without file virtual resources realized" do
        let(:pre_condition) { [
          'Group <| |>',
          'User <| |>'
        ] }

        it { is_expected.to contain_file('/data').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d').with(
          'ensure' => 'directory',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755'
        ) }
      end
    end
  end
end
