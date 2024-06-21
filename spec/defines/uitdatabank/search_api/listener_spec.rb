describe 'profiles::uitdatabank::search_api::listener' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with title => foo' do
        let(:title) { 'foo' }

        context 'with command => consume-foo-api' do
          let(:params) { {
            'command' => 'consume-foo-api'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__uitdatabank__search_api__listener('foo').with(
            'command' => 'consume-foo-api',
            'basedir' => '/var/www/udb3-search-service',
            'ensure'  => 'present'
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_systemd__unit_file('foo.service').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^Group=www-data$/) }
          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^User=www-data$/) }
          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^WorkingDirectory=\/var\/www\/udb3-search-service$/) }
          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^ExecStart=\/usr\/bin\/php bin\/app.php consume-foo-api$/) }

          it { is_expected.to contain_service('foo').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_group('www-data').that_comes_before('Service[foo]') }
          it { is_expected.to contain_user('www-data').that_comes_before('Service[foo]') }
          it { is_expected.to contain_systemd__unit_file('foo.service').that_notifies('Service[foo]') }
        end

        context 'with command => consume-udb3-api' do
          let(:params) { {
            'command' => 'consume-udb3-api',
            'basedir' => '/var/www/baz'
          } }

          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^WorkingDirectory=\/var\/www\/baz$/) }
          it { is_expected.to contain_systemd__unit_file('foo.service').with_content(/^ExecStart=\/usr\/bin\/php bin\/app.php consume-udb3-api$/) }
        end

        context 'with ensure => absent' do
          let(:params) { {
            'ensure' => 'absent'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.not_to contain_group('www-data') }
          it { is_expected.not_to contain_user('www-data') }

          it { is_expected.to contain_systemd__unit_file('foo.service').with(
            'ensure' => 'absent'
          ) }

          it { is_expected.not_to contain_service('foo') }
        end

        context 'without parameters' do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'command'/) }
        end
      end

      context 'with title => bar' do
        let(:title) { 'bar' }

        context 'with command => bar-baz' do
          let(:params) { {
            'command' => 'bar-baz'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__uitdatabank__search_api__listener('bar').with(
            'command' => 'bar-baz',
            'basedir' => '/var/www/udb3-search-service',
            'ensure'  => 'present'
          ) }

          it { is_expected.to contain_group('www-data') }
          it { is_expected.to contain_user('www-data') }

          it { is_expected.to contain_systemd__unit_file('bar.service').with(
            'ensure' => 'present'
          ) }

          it { is_expected.to contain_systemd__unit_file('bar.service').with_content(/^Group=www-data$/) }
          it { is_expected.to contain_systemd__unit_file('bar.service').with_content(/^User=www-data$/) }
          it { is_expected.to contain_systemd__unit_file('bar.service').with_content(/^WorkingDirectory=\/var\/www\/udb3-search-service$/) }
          it { is_expected.to contain_systemd__unit_file('bar.service').with_content(/^ExecStart=\/usr\/bin\/php bin\/app.php bar-baz$/) }

          it { is_expected.to contain_service('bar').with(
            'ensure'    => 'running',
            'enable'    => true,
            'hasstatus' => true
          ) }

          it { is_expected.to contain_group('www-data').that_comes_before('Service[bar]') }
          it { is_expected.to contain_user('www-data').that_comes_before('Service[bar]') }
          it { is_expected.to contain_systemd__unit_file('bar.service').that_notifies('Service[bar]') }
        end
      end
    end
  end
end
