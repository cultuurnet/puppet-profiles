describe 'profiles::uit::api::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::api::logging').with(
          'deployment' => true
        ) }

        it { is_expected.to contain_profiles__rsyslog__tag_filter('uit-api').with(
          'syslogtag'   => 'uit-api',
          'destination' => '/var/log/uit-api.log'
        ) }
      end

      context "with deployment => false" do
        let(:params) { {
          'deployment' => false
        } }

        it { is_expected.not_to contain_profiles__rsyslog__tag_filter('uit-api') }
      end
    end
  end
end
