describe 'profiles::python' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::python').with(
          'with_dev' => false
        ) }

        it { is_expected.to contain_package('python3').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.not_to contain_package('python3-pip') }
        it { is_expected.not_to contain_profiles__jenkins__node_labels('python') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          context "with Python available" do
            case facts[:os]['release']['major']
            when '20.04'
              let(:facts) { facts.merge({ 'python3_release' => '3.8' }) }

              it { is_expected.to contain_profiles__jenkins__node_labels('python').with(
                'content' => 'python3.8'
              ) }
            when '24.04'
              let(:facts) { facts.merge({ 'python3_release' => '3.12' }) }

              it { is_expected.to contain_profiles__jenkins__node_labels('python').with(
                'content' => 'python3.12'
              ) }
            end
          end
        end
      end

      context 'with with_dev => true' do
        let(:params) { { 'with_dev' => true } }

        it { is_expected.to contain_package('python3').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_package('python3-pip').with(
          'ensure' => 'installed'
        ) }
      end
    end
  end
end
