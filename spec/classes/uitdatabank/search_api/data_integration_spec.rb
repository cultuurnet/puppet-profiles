describe 'profiles::uitdatabank::search_api::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::data_integration').with(
          'bucket_dumplocation' => '',
          'dump_schedule'       => true,
          'dump_hour'           => 0,
          'timezone'            => 'UTC'
        ) }

        it { is_expected.to contain_class('profiles::data_integration') }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=UTC', 'MAILTO=infra+cron@publiq.be'],
          'command'     => '/usr/bin/test $(date +\\%0H) -eq 0 && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*',
          'hour'        => '*',
          'minute'      => '00'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').that_requires('Class[profiles::data_integration]') }
        it { is_expected.to contain_file('elasticdump_to_gcs').that_comes_before('Cron[elasticdump_to_gcs]') }
      end

      context 'with bucket_dumplocation => bar, dump_hour => 2 and timezone => CEST' do
        let(:params) { {
          'bucket_dumplocation' => 'bar',
          'dump_hour'           => 2,
          'timezone'            => 'CEST'
        } }

        it { is_expected.to contain_class('profiles::data_integration') }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_dumplocation=bar$/) }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure'      => 'present',
          'environment' => ['SHELL=/bin/bash', 'TZ=CEST', 'MAILTO=infra+cron@publiq.be'],
          'command'     => '/usr/bin/test $(date +\\%0H) -eq 2 && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*',
          'hour'        => '*',
          'minute'      => '00'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').that_requires('Class[profiles::data_integration]') }
        it { is_expected.to contain_file('elasticdump_to_gcs').that_comes_before('Cron[elasticdump_to_gcs]') }
      end

      context 'with dump_schedule => false' do
        let(:params) { {
          'dump_schedule'       => false
        } }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure' => 'absent'
        ) }
      end
    end
  end
end
