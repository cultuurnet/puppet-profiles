describe 'profiles::java' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java').with(
          'installed_versions' => 8,
          'distribution'       => 'jre',
          'headless'           => true,
          'default_version'    => 8
        ) }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 8,
          'distribution'    => 'jre',
          'headless'        => true
        ) }

        it { is_expected.to contain_package('openjdk-8-jre-headless') }
        it { is_expected.not_to contain_profiles__jenkins__node_labels('openjdk-8') }

        it { is_expected.to contain_package('openjdk-8-jre-headless').that_comes_before('Class[profiles::java::alternatives]') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          it { is_expected.to contain_profiles__jenkins__node_labels('openjdk-8').with(
            'content' => 'java8'
          ) }
        end
      end

      context "with installed_versions => [17, 8], distribution => jdk and headless => false" do
        let(:params) { {
          'installed_versions' => [17, 8],
          'distribution'       => 'jdk',
          'headless'           => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java').with(
          'installed_versions' => [17, 8],
          'distribution'       => 'jdk',
          'headless'           => false,
          'default_version'    => 17
        ) }

        it { is_expected.to contain_package('openjdk-8-jdk') }
        it { is_expected.to contain_package('openjdk-17-jdk') }

        it { is_expected.not_to contain_profiles__jenkins__node_labels('openjdk-17').with(
          'content' => 'java17'
        ) }

        it { is_expected.not_to contain_profiles__jenkins__node_labels('openjdk-8').with(
          'content' => 'java8'
        ) }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 17,
          'distribution'    => 'jdk',
          'headless'        => false
        ) }

        it { is_expected.to contain_package('openjdk-8-jdk').that_comes_before('Class[profiles::java::alternatives]') }
        it { is_expected.to contain_package('openjdk-17-jdk').that_comes_before('Class[profiles::java::alternatives]') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          it { is_expected.to contain_profiles__jenkins__node_labels('openjdk-17').with(
            'content' => 'java17'
          ) }

          it { is_expected.to contain_profiles__jenkins__node_labels('openjdk-8').with(
            'content' => 'java8'
          ) }
        end
      end

      context "with installed_versions => [8, 11] and default_version => 11" do
        let(:params) { {
          'installed_versions' => [8, 11],
          'default_version'    => 11,
          'headless'           => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_package('openjdk-8-jre') }
        it { is_expected.to contain_package('openjdk-11-jre') }

        it { is_expected.not_to contain_profiles__jenkins__node_labels('openjdk-8') }
        it { is_expected.not_to contain_profiles__jenkins__node_labels('openjdk-11') }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 11,
          'distribution'    => 'jre',
          'headless'        => false
        ) }

        it { is_expected.to contain_package('openjdk-8-jre').that_comes_before('Class[profiles::java::alternatives]') }
        it { is_expected.to contain_package('openjdk-11-jre').that_comes_before('Class[profiles::java::alternatives]') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          it { is_expected.to contain_profiles__jenkins__node_labels('openjdk-8').with(
            'content' => 'java8'
          ) }

          it { is_expected.to contain_profiles__jenkins__node_labels('openjdk-11').with(
            'content' => 'java11'
          ) }
        end
      end

      context "with installed_versions => [13, 14] and default_version => 13" do
        let(:params) { {
          'installed_versions' => [13, 14],
          'default_version'    => 13
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /OpenJDK version 13 is not installable/) }
      end

      context "with installed_versions => [16, 17] and default_version => 13" do
        let(:params) { {
          'installed_versions' => [16, 17],
          'default_version'    => 13
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /Default OpenJDK version 13 is not installed/) }
      end
    end
  end
end
