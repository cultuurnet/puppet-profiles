describe 'profiles::jenkins::agent' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with hieradata' do
        let(:hiera_config) { 'spec/support/hiera/common.yaml' }

        context 'on node jenkins1.example.com' do
          let(:node) { 'jenkins1.example.com' }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_class('profiles::jenkins::agent').with(
              'bootstrap' => false
            ) }

            it { is_expected.to contain_class('profiles::jenkins::node') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::bootstrap') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::extra') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::playwright') }

            it { is_expected.to contain_class('profiles::python').with(
              'with_dev' => true
            ) }

            it { is_expected.to contain_class('profiles::ruby').with(
              'with_dev' => true
            ) }

            it { is_expected.to contain_profiles__puppet__puppetdb__cli('jenkins') }

            it { expect(exported_resources).to contain_profiles__vault__trusted_certificate('jenkins1.example.com').with(
              'policies' => ['jenkins_certificate']
            ) }

            it { is_expected.to contain_file('node-cleanup-script').with(
              'ensure' => 'file',
              'path'   => '/usr/local/bin/node-cleanup.sh',
              'mode'   => '0755'
            )}

            it { is_expected.to contain_file('node-cleanup-script').with_content(/^hostname=jenkins1\.example\.com/) }
            it { is_expected.to contain_file('node-cleanup-script').with_content(/^puppetserver_url=https:\/\/puppetserver\.example\.com:8140/) }
            it { is_expected.to contain_file('node-cleanup-script').with_content(/^puppetdb_url=http:\/\/localhost:8081/) }
          end
        end

        context 'on node jenkins2.example.com' do
          let(:node) { 'jenkins2.example.com' }

          context 'with bootstrap => true' do
            let(:params) { {
              'bootstrap' => true
            } }

            it { is_expected.to contain_class('profiles::jenkins::node') }
            it { is_expected.to contain_class('profiles::jenkins::buildtools::bootstrap') }

            it { is_expected.to contain_class('profiles::python').with(
              'with_dev' => true
            ) }

            it { is_expected.to contain_class('profiles::ruby').with(
              'with_dev' => true
            ) }

            it { is_expected.not_to contain_class('profiles::jenkins::buildtools::extra') }
            it { is_expected.not_to contain_class('profiles::jenkins::buildtools::playwright') }

            it { is_expected.not_to contain_profiles__puppet__puppetdb__cli('jenkins') }
            it { expect(exported_resources).not_to contain_profiles__vault__trusted_certificate('jenkins1.example.com') }
            it { is_expected.not_to contain_file('node-cleanup-script') }
          end
        end
      end
    end
  end
end
