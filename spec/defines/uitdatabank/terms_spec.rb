describe 'profiles::uitdatabank::terms' do
  context "with title => foobar" do
    let(:title) { 'foobar' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with directory => /tmp, facilities_mapping_source => /var/foo, themes_mapping_source => /var/bar and types_mapping_source => /var/bla" do
          let(:params) { {
            'directory'                 => '/tmp',
            'facilities_mapping_source' => '/var/foo',
            'themes_mapping_source'     => '/var/bar',
            'types_mapping_source'      => '/var/bla'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__uitdatabank__terms('foobar').with(
            'directory'                   => '/tmp',
            'facilities_mapping_source'   => '/var/foo',
            'themes_mapping_source'       => '/var/bar',
            'types_mapping_source'        => '/var/bla',
            'facilities_mapping_filename' => 'config.term_mapping_facilities.php',
            'themes_mapping_filename'     => 'config.term_mapping_themes.php',
            'types_mapping_filename'      => 'config.term_mapping_types.php'
          ) }

          it { is_expected.to contain_file('foobar config.term_mapping_facilities.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644',
            'path'   => '/tmp/config.term_mapping_facilities.php',
            'source' => '/var/foo'
          ) }

          it { is_expected.to contain_file('foobar config.term_mapping_themes.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644',
            'path'   => '/tmp/config.term_mapping_themes.php',
            'source' => '/var/bar'
          ) }

          it { is_expected.to contain_file('foobar config.term_mapping_types.php').with(
            'ensure' => 'file',
            'owner'  => 'www-data',
            'group'  => 'www-data',
            'mode'   => '0644',
            'path'   => '/tmp/config.term_mapping_types.php',
            'source' => '/var/bla'
          ) }

          it { is_expected.to contain_file('foobar config.term_mapping_facilities.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foobar config.term_mapping_facilities.php').that_requires('User[www-data]') }
          it { is_expected.to contain_file('foobar config.term_mapping_themes.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foobar config.term_mapping_themes.php').that_requires('User[www-data]') }
          it { is_expected.to contain_file('foobar config.term_mapping_types.php').that_requires('Group[www-data]') }
          it { is_expected.to contain_file('foobar config.term_mapping_types.php').that_requires('User[www-data]') }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'directory'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'facilities_mapping_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'themes_mapping_source'/) }
          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'types_mapping_source'/) }
        end
      end
    end
  end

  context "with title => myterms" do
    let(:title) { 'myterms' }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        context "with directory => /tmp, facilities_mapping_source => /var/foo, themes_mapping_source => /var/bar and types_mapping_source => /var/bla" do
          let(:params) { {
            'directory'                   => '/var/www',
            'facilities_mapping_source'   => '/tmp/source1',
            'themes_mapping_source'       => '/tmp/source2',
            'types_mapping_source'        => '/tmp/source3',
            'facilities_mapping_filename' => 'dest1',
            'themes_mapping_filename'     => 'dest2',
            'types_mapping_filename'      => 'dest3'
          } }

          it { is_expected.to contain_file('myterms dest1').with(
            'path'   => '/var/www/dest1',
            'source' => '/tmp/source1'
          ) }

          it { is_expected.to contain_file('myterms dest2').with(
            'path'   => '/var/www/dest2',
            'source' => '/tmp/source2'
          ) }

          it { is_expected.to contain_file('myterms dest3').with(
            'path'   => '/var/www/dest3',
            'source' => '/tmp/source3'
          ) }
        end
      end
    end
  end
end
