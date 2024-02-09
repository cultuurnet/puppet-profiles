describe 'profiles::uit::cms::deployment' do
  context "with config_source => /foo and drush_config_source => /bar" do
    let(:params) { {
      'config_source'     => '/foo',
      'drush_config_source' => '/bar'
    } }

    include_examples 'operating system support'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('uit-cms') }

        context "without hieradata" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
            'puppetdb_url' => nil
          ) }
        end

        context "with hieradata" do
          let(:hiera_config) { 'spec/support/hiera/common.yaml' }

          it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
            'puppetdb_url' => 'http://localhost:8081'
          ) }
        end
      end
    end
  end

  context "with config_source => /baz, drush_config_source => /zzz, version => 1.2.3 and puppetdb_url => http://example.com:8000" do
    let(:params) { {
      'config_source'     => '/baz',
      'drush_config_source' => '/zzz',
      'version'             => '1.2.3',
      'puppetdb_url'        => 'http://example.com:8000'
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to contain_profiles__deployment__versions('profiles::uit::cms::deployment').with(
          'puppetdb_url' => 'http://example.com:8000'
        ) }
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'drush_config_source'/) }
      end
    end
  end
end
