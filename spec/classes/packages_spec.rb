require 'spec_helper'

describe 'profiles::packages' do
  let(:pre_condition) { 'include ::profiles' }

  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'Package <| |>',
          'Apt::Source <| |>',
          'Profiles::Apt::Update <| |>'
        ] }

        it { is_expected.to contain_package('composer').with(
          'ensure' => 'absent'
          )
        }

        it { is_expected.to contain_package('composer1').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('composer1').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('composer2').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('composer2').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('drush').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('amqp-tools').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('awscli').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('graphviz').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('fontconfig').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('ca-certificates-publiq').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('ca-certificates-publiq').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('jq').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('gcsfuse').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('gcsfuse').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('liquibase').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('liquibase').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('mysql-connector-java').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('mysql-connector-java').that_requires('Profiles::Apt::Update[cultuurnet-tools]') }

        it { is_expected.to contain_package('yarn').with(
          'ensure' => 'present'
          )
        }

        it { is_expected.to contain_package('yarn').that_requires('Profiles::Apt::Update[yarn]') }
      end
    end
  end
end
