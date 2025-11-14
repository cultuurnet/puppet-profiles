describe 'profiles::uitdatabank::entry_api::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'on node node1.example.com' do
        let(:node) { 'node1.example.com' }

        context 'with database_name => foobar' do
          let(:params) { {
            'database_name' => 'foobar'
          } }

          context 'without extra parameters' do
            let(:params) { super() }

            context 'with hieradata' do
              let(:hiera_config) { 'spec/support/hiera/common.yaml' }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').with(
                'database_name'             => 'foobar',
                'database_host'             => '127.0.0.1',
                'popularity_score_password' => nil,
                'similarities_password'     => nil,
                'event_labeling_password'   => nil,
                'duplicate_places_password' => nil
              ) }

              it { is_expected.to contain_class('profiles::data_integration') }

              it { is_expected.to have_profiles__mysql__app_user_resource_count(1) }

              it { is_expected.to contain_profiles__mysql__app_user('ownership_search@foobar').with(
                'user'     => 'ownership_search',
                'database' => 'foobar',
                'tables'   => ['ownership_search'],
                'readonly' => true,
                'remote'   => false,
                'password' => '8bZs9RqRT2k22qa13HDI'
              ) }

              it { is_expected.to contain_profiles__sling__connection('foobar').with(
                'type'          => 'mysql',
                'configuration' => {
                                     'user'     => 'ownership_search',
                                     'password' => '8bZs9RqRT2k22qa13HDI',
                                     'host'     => '127.0.0.1',
                                     'database' => 'foobar'
                                   }
              ) }

              it { is_expected.to contain_file('parquetdump_to_gcs').with(
                'ensure' => 'file',
                'path'   => '/usr/local/bin/parquetdump_to_gcs',
                'mode'   => '0755'
              ) }

              it { is_expected.to contain_cron('parquetdump_to_gcs').with(
                'ensure'      => 'present',
                'command'     => '/usr/local/bin/parquetdump_to_gcs',
                'environment' => ['SHELL=/bin/bash', 'MAILTO=infra+cron@publiq.be'],
                'hour'        => 2,
                'minute'      => 30
              ) }

              it { is_expected.to contain_profiles__sling__connection('foobar').that_requires('Profiles::Mysql::App_user[ownership_search@foobar]') }
              it { is_expected.to contain_file('parquetdump_to_gcs').that_requires('Profiles::Sling::Connection[foobar]') }
              it { is_expected.to contain_cron('parquetdump_to_gcs').that_requires('File[parquetdump_to_gcs]') }
            end
          end

          context 'with database_host => foo.example.com, popularity_score_password => foo and event_labeling_password => bar' do
            let(:params) { super().merge({
              'database_host'             => 'foo.example.com',
              'popularity_score_password' => 'foo',
              'event_labeling_password'   => 'bar'
            }) }

            context 'with hieradata' do
              let(:hiera_config) { 'spec/support/hiera/common.yaml' }

              it { is_expected.to contain_profiles__mysql__app_user('ownership_search@foobar').with(
                'user'     => 'ownership_search',
                'database' => 'foobar',
                'tables'   => ['ownership_search'],
                'readonly' => true,
                'remote'   => true,
                'password' => '8bZs9RqRT2k22qa13HDI'
              ) }

              it { is_expected.to contain_profiles__sling__connection('foobar').with(
                'type'          => 'mysql',
                'configuration' => {
                                     'user'     => 'ownership_search',
                                     'password' => '8bZs9RqRT2k22qa13HDI',
                                     'host'     => 'foo.example.com',
                                     'database' => 'foobar'
                                   }
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('popularity_score@foobar').with(
                'user'     => 'popularity_score',
                'database' => 'foobar',
                'tables'   => ['offer_popularity'],
                'remote'   => true,
                'password' => 'foo'
              ) }

              it { is_expected.to contain_profiles__mysql__app_user('event_labeling@foobar').with(
                'user'     => 'event_labeling',
                'database' => 'foobar',
                'tables'   => ['labels_import'],
                'remote'   => true,
                'password' => 'bar'
              ) }

              it { is_expected.to have_profiles__mysql__app_user_resource_count(3) }
            end
          end
        end
      end

      context 'on node node2.example.com' do
        let(:node) { 'node2.example.com' }

        context 'with database_name => mydb, database_host => db.example.com, popularity_score_password => baz, similar_events_password => secret, event_labeling_password => test and duplicate_places_password => l33t' do
          let(:params) { {
            'database_name'             => 'mydb',
            'database_host'             => 'db.example.com',
            'popularity_score_password' => 'baz',
            'similar_events_password'   => 'secret',
            'event_labeling_password'   => 'test',
            'duplicate_places_password' => 'l33t'
          } }

          context 'with hieradata' do
            let(:hiera_config) { 'spec/support/hiera/common.yaml' }

            it { is_expected.to contain_class('profiles::data_integration') }

            it { is_expected.to contain_profiles__mysql__app_user('ownership_search@mydb').with(
              'user'     => 'ownership_search',
              'database' => 'mydb',
              'tables'   => ['ownership_search'],
              'readonly' => true,
              'remote'   => true,
              'password' => 'BzVHekhi7SGdyRaQEDZY'
            ) }

            it { is_expected.to contain_profiles__sling__connection('mydb').with(
              'type'          => 'mysql',
              'configuration' => {
                                   'user'     => 'ownership_search',
                                   'password' => 'BzVHekhi7SGdyRaQEDZY',
                                   'host'     => 'db.example.com',
                                   'database' => 'mydb'
                                 }
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('popularity_score@mydb').with(
              'user'     => 'popularity_score',
              'database' => 'mydb',
              'tables'   => ['offer_popularity'],
              'remote'   => true,
              'password' => 'baz'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('similar_events@mydb').with(
              'user'     => 'similar_events',
              'database' => 'mydb',
              'tables'   => ['similar_events'],
              'remote'   => true,
              'password' => 'secret'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('event_labeling@mydb').with(
              'user'     => 'event_labeling',
              'database' => 'mydb',
              'tables'   => ['labels_import'],
              'remote'   => true,
              'password' => 'test'
            ) }

            it { is_expected.to contain_profiles__mysql__app_user('duplicate_places@mydb').with(
              'user'     => 'duplicate_places',
              'database' => 'mydb',
              'tables'   => ['duplicate_places_import', 'duplicate_places_removed_from_cluster_import'],
              'remote'   => true,
              'password' => 'l33t'
            ) }

            it { is_expected.to have_profiles__mysql__app_user_resource_count(5) }

            it { is_expected.to contain_profiles__sling__connection('mydb').that_requires('Profiles::Mysql::App_user[ownership_search@mydb]') }
          end
        end
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_name'/) }
      end
    end
  end
end
