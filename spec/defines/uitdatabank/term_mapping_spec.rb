describe 'profiles::uitdatabank::term_mapping' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with title => foo' do
        let(:title) { 'foo' }

        context 'with basedir => /var/www, facilities_source => /tmp/facilities, themes_source => /tmp/themes and types_source => /tmp/types' do
          let(:params) { {
            'basedir'           => '/var/www',
            'facilities_source' => '/tmp/facilities',
            'themes_source'     => '/tmp/themes',
            'types_source'      => '/tmp/types'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__uitdatabank__term_mapping('foo').with(
            'basedir'                     => '/var/www',
            'facilities_source'           => '/tmp/facilities',
            'themes_source'               => '/tmp/themes',
            'types_source'                => '/tmp/types',
            'facilities_mapping_filename' => 'facet_mapping_facilities.yml',
            'themes_mapping_filename'     => 'facet_mapping_themes.yml',
            'types_mapping_filename'      => 'facet_mapping_types.yml'
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_file('foo facilities').with(
            'ensure' => 'file',
            'path'   => '/var/www/facet_mapping_facilities.yml',
            'source' => '/tmp/facilities',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('foo themes').with(
            'ensure' => 'file',
            'path'   => '/var/www/facet_mapping_themes.yml',
            'source' => '/tmp/themes',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('foo types').with(
            'ensure' => 'file',
            'path'   => '/var/www/facet_mapping_types.yml',
            'source' => '/tmp/types',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('foo facilities').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foo facilities').that_requires('User[www-data]') }
          it { is_expected.to contain_file('foo themes').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foo themes').that_requires('User[www-data]') }
          it { is_expected.to contain_file('foo types').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foo types').that_requires('User[www-data]') }
        end

        context 'with basedir => /var/www/html, facilities_source => /tmp/facilities.php, themes_source => /tmp/themes.php, types_source => /tmp/types.php, facilities_mapping_filename => config.term_mapping_facilities.php, themes_mapping_filename => config.term_mapping_themes.php and types_mapping_filename => config.term_mapping_types.php' do
          let(:params) { {
            'basedir'                     => '/var/www/html',
            'facilities_source'           => '/tmp/facilities.php',
            'themes_source'               => '/tmp/themes.php',
            'types_source'                => '/tmp/types.php',
            'facilities_mapping_filename' => 'config.term_mapping_facilities.php',
            'themes_mapping_filename'     => 'config.term_mapping_themes.php',
            'types_mapping_filename'      => 'config.term_mapping_types.php'
          } }

          it { is_expected.to contain_file('foo facilities').with(
            'ensure' => 'file',
            'path'   => '/var/www/html/config.term_mapping_facilities.php',
            'source' => '/tmp/facilities.php',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('foo themes').with(
            'ensure' => 'file',
            'path'   => '/var/www/html/config.term_mapping_themes.php',
            'source' => '/tmp/themes.php',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('foo types').with(
            'ensure' => 'file',
            'path'   => '/var/www/html/config.term_mapping_types.php',
            'source' => '/tmp/types.php',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'basedir'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'facilities_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'themes_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'types_source'/) }
        end
      end

      context 'with title => bar' do
        let(:title) { 'bar' }

        context 'with basedir => /var/tmp, facilities_source => /tmp/facilities, themes_source => /tmp/themes and types_source => /tmp/types' do
          let(:params) { {
            'basedir'           => '/var/tmp',
            'facilities_source' => '/tmp/facilities',
            'themes_source'     => '/tmp/themes',
            'types_source'      => '/tmp/types'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('bar facilities').with(
            'ensure' => 'file',
            'path'   => '/var/tmp/facet_mapping_facilities.yml',
            'source' => '/tmp/facilities',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('bar themes').with(
            'ensure' => 'file',
            'path'   => '/var/tmp/facet_mapping_themes.yml',
            'source' => '/tmp/themes',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }

          it { is_expected.to contain_file('bar types').with(
            'ensure' => 'file',
            'path'   => '/var/tmp/facet_mapping_types.yml',
            'source' => '/tmp/types',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644'
          ) }
        end
      end
    end
  end
end
