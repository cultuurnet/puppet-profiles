describe 'profiles::packages' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context "with all virtual resources realized" do
        let(:pre_condition) { [
          'Package <| |>',
          'Apt::Source <| |>'
        ] }

        it { is_expected.to contain_package('composer').with(
          'ensure' => 'absent'
        ) }

        it { is_expected.to contain_package('composer1').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('composer2').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('groovy').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('amqp-tools').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('graphviz').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('ca-certificates-publiq').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('jq').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('yq').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('gcsfuse').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('liquibase').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('mysql-connector-j').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('yarn').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('bundler').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('qemu-user-static').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('build-essential').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('mysql-client').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('nfs-common').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('iftop').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('borgbackup').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('borgmatic').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('kubectl').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('argocd').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('google-cloud-cli').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('rubygem-angular-config').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('imagemagick').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('phantomjs').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('prince').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('debhelper').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('golang').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('composer1').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('composer2').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('drush').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('ca-certificates-publiq').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('gcsfuse').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('liquibase').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('mysql-connector-j').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('yarn').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('rubygem-puppetdb-cli').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('kubectl').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('argocd').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('google-cloud-cli').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('rubygem-angular-config').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('prince').that_requires('Apt::Source[publiq-tools]') }
      end

      context "without package virtual resources realized" do
        let(:pre_condition) { [
          'Apt::Source <| |>'
        ] }

        it { is_expected.to contain_package('jq').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('yq').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('iftop').with(
          'ensure' => 'present'
        ) }
      end
    end
  end
end
