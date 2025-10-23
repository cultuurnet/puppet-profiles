describe 'profiles::uitid::api::cron' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { { } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitid::api::cron').with(
          'portbase' => 4800
        ) }

        it { is_expected.to contain_cron('Clear UiTiD application caches').with(
          'command'  => "/usr/bin/curl --fail --silent --output /dev/null 'http://127.0.0.1:4880/uitid/rest/bootstrap/clearcaches'",
          'hour'     => [4, 16],
          'minute'   => 20,
          'weekday'  => '*',
          'monthday' => '*',
          'month'    => '*'
        ) }

        it { is_expected.to contain_cron('Clear UiTiD JPA cache').with(
          'command'  => "/usr/bin/curl --fail --silent --output /dev/null 'http://127.0.0.1:4880/uitid/rest/bootstrap/clearJpaCache'",
          'hour'     => [4, 16],
          'minute'   => 20,
          'weekday'  => '*',
          'monthday' => '*',
          'month'    => '*'
        ) }
      end

      context "with portbase => 14800" do
        let(:params) { {
          'portbase' => 14800
        } }

        it { is_expected.to contain_cron('Clear UiTiD application caches').with(
          'command'  => "/usr/bin/curl --fail --silent --output /dev/null 'http://127.0.0.1:14880/uitid/rest/bootstrap/clearcaches'",
          'hour'     => [4, 16],
          'minute'   => 20,
          'weekday'  => '*',
          'monthday' => '*',
          'month'    => '*'
        ) }

        it { is_expected.to contain_cron('Clear UiTiD JPA cache').with(
          'command'  => "/usr/bin/curl --fail --silent --output /dev/null 'http://127.0.0.1:14880/uitid/rest/bootstrap/clearJpaCache'",
          'hour'     => [4, 16],
          'minute'   => 20,
          'weekday'  => '*',
          'monthday' => '*',
          'month'    => '*'
        ) }
      end
    end
  end
end
