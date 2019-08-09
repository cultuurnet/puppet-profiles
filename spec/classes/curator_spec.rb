require 'spec_helper'

describe 'profiles::curator' do
  let(:pre_condition) { 'include ::profiles' }

  context "with articlelinker_config_source => /foo, articlelinker_publishers_source => /bar, api_config_source => /baz and api_hostname => example.com" do
    let(:params) { {
      'articlelinker_config_source'     => '/foo',
      'articlelinker_publishers_source' => '/bar',
      'api_config_source'               => '/baz',
      'api_hostname'                    => 'example.com'
    } }

    include_examples 'operating system support', 'profiles::curator'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        context "with all virtual resources realized" do
          let(:pre_condition) { 'include ::profiles; Apt::Source <| |>' }


          it { is_expected.to compile.with_all_deps }

          context "in the testing environment" do
            let(:environment) { 'testing' }

            it { is_expected.to contain_apt__source('publiq-curator').with(
              'location' => 'http://apt.uitdatabank.be/curator-testing',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }
          end

          context "in the production environment" do
            let(:environment) { 'production' }

            it { is_expected.to contain_apt__source('publiq-curator').with(
              'location' => 'http://apt.uitdatabank.be/curator-production',
              'ensure'   => 'present',
              'repos'    => 'main',
              'include'  => {
                'deb' => 'true',
                'src' => 'false'
              },
              'release' => 'trusty'
            )
            }
          end
        end
      end
    end
  end

  context "without parameters" do
    let(:params) { {} }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let (:facts) { facts }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'articlelinker_publishers_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_config_source'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'api_hostname'/) }
      end
    end
  end
end
