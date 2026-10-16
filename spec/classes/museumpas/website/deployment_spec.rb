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
    end
  end
end
