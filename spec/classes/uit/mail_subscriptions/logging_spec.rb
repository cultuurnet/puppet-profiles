describe 'profiles::uit::mail_subscriptions::logging' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uit::mail_subscriptions::logging').with(
          'deployment' => true
        ) }

        it { is_expected.to contain_profiles__rsyslog__tag_filter('uit-mail-subscriptions').with(
          'syslogtag'   => 'uit-mail-subscriptions',
          'destination' => '/var/log/uit-mail-subscriptions.log'
        ) }
      end

      context "with deployment => false" do
        let(:params) { {
          'deployment' => false
        } }

        it { is_expected.not_to contain_profiles__rsyslog__tag_filter('uit-mail-subscriptions') }
      end
    end
  end
end
