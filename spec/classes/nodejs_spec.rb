describe 'profiles::nodejs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::nodejs').with(
          'major_version' => 16,
          'version'       => nil,
        ) }

        it { is_expected.to contain_apt__source('nodejs-16') }
        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_class('nodejs').with(
          'manage_package_repo'   => false,
          'nodejs_package_ensure' => 'present'
        ) }

        it { is_expected.to contain_package('yarn').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[nodejs-16]') }
        it { is_expected.to contain_package('yarn').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('yarn').that_requires('Class[nodejs]') }
      end

      context "with major_version => 18" do
        let(:params) { { 'major_version' => 18 } }

        it { is_expected.to contain_apt__source('nodejs-18') }

        it { is_expected.to contain_class('nodejs').with(
          'manage_package_repo'   => false,
          'nodejs_package_ensure' => 'present'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[nodejs-18]') }
      end

      context "with version => 20.2.0-1nodesource1" do
        let(:params) { { 'version' => '20.2.0-1nodesource1' } }

        it { is_expected.to contain_apt__source('nodejs-20') }

        it { is_expected.to contain_class('nodejs').with(
          'nodejs_package_ensure' => '20.2.0-1nodesource1'
        ) }

        it { is_expected.to contain_class('nodejs').that_requires('Apt::Source[nodejs-20]') }
      end

      context "with version => 18.2.0-1nodesource1 and major_version => 20" do
        let(:params) { {
          'version'       => '18.2.0-1nodesource1',
          'major_version' => 20
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /incompatible combination of 'version' and 'major_version' parameters/) }
      end
    end
  end
end
