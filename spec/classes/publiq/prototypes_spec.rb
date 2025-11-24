describe 'profiles::publiq::prototypes' do
  let(:hiera_config) { 'spec/support/hiera/common.yaml' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => 'http://prototypes.local'" do
        let(:params) { {
          'url'          => 'http://prototypes.local'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::publiq::prototypes').with(
          'url'        => 'http://prototypes.local',
          'deployment' => true
        ) }

        it { is_expected.to contain_class('profiles::publiq::prototypes::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__basic('http://prototypes.local').with(
          'documentroot'         => '/var/www/prototypes',
          'serveraliases'        => ['*.prototypes.local'],
          'virtual_documentroot' => '/var/www/prototypes/%1'
        ) }
      end

      context "with url => http://prototypes.publiq.dev and deployment => false" do
        let(:params) { {
          'url'        => 'http://prototypes.publiq.dev',
          'deployment' => false
        } }

        it { is_expected.to_not contain_class('profiles::publiq::prototypes::deployment') }

        it { is_expected.to contain_profiles__apache__vhost__basic('http://prototypes.publiq.dev').with(
          'documentroot'         => '/var/www/prototypes',
          'serveraliases'        => ['*.prototypes.publiq.dev'],
          'virtual_documentroot' => '/var/www/prototypes/%1'
        ) }
      end

      context "without parameters" do
        let(:params) { { } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
      end
    end
  end
end
