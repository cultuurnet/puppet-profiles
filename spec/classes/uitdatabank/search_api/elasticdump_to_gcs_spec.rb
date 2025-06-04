describe 'profiles::uitdatabank::search_api::elasticdump_to_gcs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with project_id => bla and bucket_name => foo" do
        let(:params) { {
          'project_id'  => 'bla',
          'bucket_name' => 'foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::elasticdump_to_gcs').with(
          'project_id'             => 'bla',
          'bucket_name'            => 'foo',
          'bucket_dumplocation'    => '',
          'credentials_source'     => nil,
          'dump_schedule'          => false,
          'dump_hour'              => 0,
          'local_timezone'         => 'UTC'
        ) }

        it { is_expected.to contain_profiles__google__gcloud('root').with(
          'project_id'         => 'bla',
          'credentials_source' => nil
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_name=foo$/) }
        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_dumplocation=$/) }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure'      => 'absent',
          'command'     => '/usr/bin/test $(date +\\%0H) -eq 0 && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*',
          'environment' => ['SHELL=/bin/bash', 'TZ=UTC', 'MAILTO=infra+cron@publiq.be'],
          'hour'        => '*',
          'minute'      => '00'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').that_requires('Profiles::Google::Gcloud[root]') }
        it { is_expected.to contain_cron('elasticdump_to_gcs').that_requires('File[elasticdump_to_gcs]') }
      end

      context "with project_id => foobar, bucket_name => bar, credentials_source => /tmp/secret, dump_schedule => true, bucket_dumplocation => dir1/dir2, dump_hour => 12 and local_timezone => Europe/Paris" do
        let(:params) { {
          'project_id'          => 'foobar',
          'bucket_name'         => 'bar',
          'credentials_source'  => '/tmp/secret',
          'dump_schedule'       => true,
          'bucket_dumplocation' => 'dir1/dir2',
          'dump_hour'           => 12,
          'local_timezone'      => 'Europe/Paris'
        } }

        it { is_expected.to contain_profiles__google__gcloud('root').with(
          'project_id'         => 'foobar',
          'credentials_source' => '/tmp/secret'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_name=bar$/) }
        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_dumplocation=dir1\/dir2$/) }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure'      => 'present',
          'command'     => '/usr/bin/test $(date +\\%0H) -eq 12 && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*',
          'environment' => ['SHELL=/bin/bash', 'TZ=Europe/Paris', 'MAILTO=infra+cron@publiq.be'],
          'hour'        => '*',
          'minute'      => '00'
        ) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::elasticdump_to_gcs').with(
          'project_id'          => nil,
          'bucket_name'         => nil,
          'bucket_dumplocation' => '',
          'credentials_source'  => nil,
          'dump_schedule'       => false,
          'dump_hour'           => 0,
          'local_timezone'      => 'UTC'
        ) }

        it { is_expected.to contain_profiles__google__gcloud('root').with(
          'project_id'         => nil,
          'credentials_source' => nil
        ) }

        it { is_expected.not_to contain_file('elasticdump_to_gcs') }
        it { is_expected.not_to contain_cron('elasticdump_to_gcs') }
      end
    end
  end
end
