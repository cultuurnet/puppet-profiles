describe 'profiles::museumpas::website::deployment' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:hiera_config) { 'spec/support/hiera/common.yaml' }
      let(:params) { { 'config_source' => 'appconfig/museumpas/website/env' } }

      it { is_expected.to compile.with_all_deps }

      %w[nl-app-callback.php fr-app-callback.php nl-app-signout.php fr-app-signout.php].each do |filename|
        it { is_expected.to contain_file("museumpas-#{filename}").with(
          'ensure'  => 'file',
          'path'    => "/var/www/museumpas/public/#{filename}",
          'content' => "App #{filename[/app-(callback|signout)/, 1]} (#{filename[0, 2]})\n",
          'owner'   => 'www-data',
          'group'   => 'www-data',
        ).that_requires('Package[museumpas-website]') }
      end

      context 'without well_known_source' do
        it { is_expected.not_to contain_file('museumpas-well-known-directory') }
        it { is_expected.not_to contain_file('museumpas-well-known-apple-app-site-association') }
        it { is_expected.not_to contain_file('museumpas-well-known-assetlinks.json') }
      end

      context 'with well_known_source' do
        let(:params) do
          {
            'config_source'     => 'appconfig/museumpas/website/env',
            'well_known_source' => 'appconfig/museumpas/website/.well-known',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('museumpas-well-known-directory').with(
          'ensure' => 'directory',
          'path'   => '/var/www/museumpas/public/.well-known',
          'owner'  => 'www-data',
          'group'  => 'www-data',
        ).that_requires('Package[museumpas-website]') }

        {
          'apple-app-site-association' => "{\"applinks\":{\"details\":[]}}\n",
          'assetlinks.json'           => "[]\n",
        }.each do |filename, content|
          it { is_expected.to contain_file("museumpas-well-known-#{filename}").with(
            'ensure'  => 'file',
            'path'    => "/var/www/museumpas/public/.well-known/#{filename}",
            'content' => content,
            'owner'   => 'www-data',
            'group'   => 'www-data',
          ).that_requires('File[museumpas-well-known-directory]') }
        end
      end
    end
  end
end
