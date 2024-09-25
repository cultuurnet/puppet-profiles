describe 'profiles::uitdatabank::entry_api::data_integration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with database_name => foobar' do
        let(:params) { {
          'database_name' => 'foobar'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::entry_api::data_integration').with(
          'database_name'             => 'foobar',
          'popularity_score_password' => nil,
          'similarities_password'     => nil,
          'event_labeling_password'   => nil,
          'duplicate_places_password' => nil
        ) }

        it { is_expected.to have_profiles__mysql__app_user_resource_count(0) }
      end

      context 'with database_name => barbaz, popularity_score_password => foo and event_labeling_password => bar' do
        let(:params) { {
          'database_name'             => 'barbaz',
          'popularity_score_password' => 'foo',
          'event_labeling_password'   => 'bar'
        } }

        it { is_expected.to contain_profiles__mysql__app_user('popularity_score@barbaz').with(
          'user'     => 'popularity_score',
          'database' => 'barbaz',
          'tables'   => ['offer_popularity'],
          'remote'   => true,
          'password' => 'foo'
        ) }

        it { is_expected.to contain_profiles__mysql__app_user('event_labeling@barbaz').with(
          'user'     => 'event_labeling',
          'database' => 'barbaz',
          'tables'   => ['labels_import'],
          'remote'   => true,
          'password' => 'bar'
        ) }

        it { is_expected.to have_profiles__mysql__app_user_resource_count(2) }
      end

      context 'with database_name => mydb, popularity_score_password => baz, similar_events_password => secret, event_labeling_password => test and duplicate_places_password => l33t' do
        let(:params) { {
          'database_name'             => 'mydb',
          'popularity_score_password' => 'baz',
          'similar_events_password'   => 'secret',
          'event_labeling_password'   => 'test',
          'duplicate_places_password' => 'l33t'
        } }

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

        it { is_expected.to have_profiles__mysql__app_user_resource_count(4) }
      end

      context 'without parameters' do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'database_name'/) }
      end
    end
  end
end
