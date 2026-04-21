describe 'profiles::terraform' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::terraform').with(
          'version' => 'latest'
        ) }

        it { is_expected.to contain_apt__source('hashicorp') }

        it { is_expected.to contain_package('terraform').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.not_to contain_profiles__jenkins__node_labels('terraform') }

        it { is_expected.to contain_apt__source('hashicorp').that_comes_before('Package[terraform]') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          it { is_expected.to contain_profiles__jenkins__node_labels('terraform').with(
            'content' => 'terraform'
          ) }
        end
      end

      context "with version => 1.2.3" do
        let(:params) { {
          'version' => '1.2.3'
        } }

        it { is_expected.to contain_package('terraform').with(
          'ensure' => '1.2.3'
        ) }
      end
    end
  end
end
