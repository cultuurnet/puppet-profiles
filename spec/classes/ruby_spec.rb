describe 'profiles::ruby' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to contain_class('profiles::ruby').with(
          'with_dev'     => false
        ) }

        it { is_expected.to contain_package('ruby') }
        it { is_expected.not_to contain_package('bundler') }
        it { is_expected.not_to contain_package('git') }
        it { is_expected.not_to contain_package('ri') }
        it { is_expected.not_to contain_package('ruby-dev') }
        it { is_expected.not_to contain_package('libffi-dev') }

        it { is_expected.not_to contain_profiles__jenkins__node_labels('ruby') }

        context 'with all virtual resources collected' do
          let(:pre_condition) { 'Profiles::Jenkins::Node_labels <| |>' }

          case facts[:os]['release']['major']
          when '20.04'
            it { is_expected.to contain_profiles__jenkins__node_labels('ruby').with(
              'content' => 'ruby2.7'
            ) }
          when '24.04'
            it { is_expected.to contain_profiles__jenkins__node_labels('ruby').with(
              'content' => 'ruby3.2'
            ) }
          end
        end
      end

      context 'with_dev => true' do
        let(:params) { {
          'with_dev'     => true
        } }

        it { is_expected.to contain_package('bundler').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('git').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('ri').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('ruby-dev').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('libffi-dev').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_package('bundler').that_requires('Package[ruby]') }
      end
    end
  end
end
