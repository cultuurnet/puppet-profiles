require 'spec_helper'

describe 'profiles::php' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::php').with(
          'with_composer_default_version' => 1
        ) }

        case facts[:os]['release']['major']
        when '14.04', '16.04'
          it { is_expected.to contain_apt__source('php') }

          it { is_expected.to contain_class('php::globals').that_requires('Apt::Source[php]') }
        end

        it { is_expected.to contain_class('php').that_requires('Class[php::globals]') }

        it { is_expected.to contain_package('composer').with(
          'ensure' => 'absent'
          )
        }

        it { is_expected.to contain_package('composer1').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('composer2').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_alternatives('composer').with(
          'path' => '/usr/bin/composer1'
          )
        }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('composer1').that_requires(['Class[php]', 'Package[composer]']) }
        it { is_expected.to contain_package('composer2').that_requires(['Class[php]', 'Package[composer]']) }
        it { is_expected.to contain_alternatives('composer').that_requires(['Package[composer1]', 'Package[composer2]']) }
      end

      context 'with with_composer_default_version => 2' do
        let(:params) { {
            'with_composer_default_version' => 2
          } }

          it { is_expected.to contain_alternatives('composer').with(
            'path' => '/usr/bin/composer2'
            )
          }
      end
    end
  end
end
