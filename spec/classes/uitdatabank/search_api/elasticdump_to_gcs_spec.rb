describe 'profiles::uitdatabank::search_api::elasticdump_to_gcs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with gcs_bucket_name => foo" do
        let(:params) { {
          'gcs_bucket_name' => 'foo'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::elasticdump_to_gcs').with(
          'gcs_bucket_name'        => 'foo',
          'gcs_credentials_source' => nil,
          'schedule'               => false,
          'bucket_mountpoint'      => '/mnt/gcs',
          'bucket_dumplocation'    => '',
          'dump_hour'              => 0,
          'local_timezone'         => 'UTC'
        ) }

        it { is_expected.to contain_class('profiles::gcsfuse').with(
          'credentials_source' => nil
        ) }

        it { is_expected.to contain_file('/mnt/gcs').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^gcs_bucket_name=foo$/) }
        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_mountpoint=\/mnt\/gcs$/) }
        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_dumplocation=$/) }

        it { is_expected.to contain_cron('elasticdump_to_gcs').with(
          'ensure'      => 'absent',
          'command'     => '/usr/bin/test $(date +\\%0H) -eq 0 && /usr/local/bin/elasticdump_to_gcs /data/backup/elasticsearch/current/udb3_core_v*',
          'environment' => ['SHELL=/bin/bash', 'TZ=UTC', 'MAILTO=infra+cron@publiq.be'],
          'hour'        => '*',
          'minute'      => '00'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').that_requires('Class[profiles::gcsfuse]') }
        it { is_expected.to contain_cron('elasticdump_to_gcs').that_requires('File[elasticdump_to_gcs]') }
        it { is_expected.to contain_cron('elasticdump_to_gcs').that_requires('File[/mnt/gcs]') }
      end

      context "with gcs_bucket_name => bar, gcs_credentials_source => /tmp/secret, schedule => true, bucket_mountpoint => /mnt/bar/baz, bucket_dumplocation => dir1/dir2, dump_hour => 12 and local_timezone => Europe/Paris" do
        let(:params) { {
          'gcs_bucket_name'        => 'bar',
          'gcs_credentials_source' => '/tmp/secret',
          'schedule'               => true,
          'bucket_mountpoint'      => '/mnt/bar/baz',
          'bucket_dumplocation'    => 'dir1/dir2',
          'dump_hour'              => 12,
          'local_timezone'         => 'Europe/Paris'
        } }

        it { is_expected.to contain_class('profiles::gcsfuse').with(
          'credentials_source' => '/tmp/secret'
        ) }

        it { is_expected.to contain_file('/mnt/bar').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_file('/mnt/bar/baz').with(
          'ensure' => 'directory'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with(
          'ensure' => 'file',
          'path'   => '/usr/local/bin/elasticdump_to_gcs',
          'mode'   => '0755'
        ) }

        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^gcs_bucket_name=bar$/) }
        it { is_expected.to contain_file('elasticdump_to_gcs').with_content(/^bucket_mountpoint=\/mnt\/bar\/baz$/) }
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

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'gcs_bucket_name'/) }
      end
    end
  end
end
