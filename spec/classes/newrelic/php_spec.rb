describe 'profiles::newrelic::php' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with app_name => foo and license_key => bar" do
        let(:params) { {
          'app_name'    => 'foo',
          'license_key' => 'bar'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_apt__source('newrelic') }

        it { is_expected.to contain_class('profiles::newrelic::php').with(
          'app_name'    => 'foo',
          'license_key' => 'bar'
        ) }

        it { is_expected.to contain_file('newrelic-php5-installer.preseed').with(
          'path'   => '/var/tmp/newrelic-php5-installer.preseed',
          'mode'   => '0600',
          'backup' => false
        ) }

        it { is_expected.to contain_file('newrelic-php5-installer.preseed').with_content(/^newrelic-php5 newrelic-php5\/application-name string "foo"$/) }
        it { is_expected.to contain_file('newrelic-php5-installer.preseed').with_content(/^newrelic-php5 newrelic-php5\/license-key string "bar"$/) }

        it { is_expected.to contain_package('newrelic-php5').with(
          'ensure'       => 'latest',
          'responsefile' => '/var/tmp/newrelic-php5-installer.preseed'
        ) }

        it { is_expected.to contain_apt__source('newrelic').that_comes_before('Package[newrelic-php5]') }
        it { is_expected.to contain_file('newrelic-php5-installer.preseed').that_comes_before('Package[newrelic-php5]') }
      end

      context "with app_name => baz and license_key => secret" do
        let(:params) { {
          'app_name'    => 'baz',
          'license_key' => 'secret'
        } }

        it { is_expected.to contain_file('newrelic-php5-installer.preseed').with_content(/^newrelic-php5 newrelic-php5\/application-name string "baz"$/) }
        it { is_expected.to contain_file('newrelic-php5-installer.preseed').with_content(/^newrelic-php5 newrelic-php5\/license-key string "secret"$/) }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'app_name'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'license_key'/) }
      end
    end
  end
end
