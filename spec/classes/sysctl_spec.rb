describe 'profiles::sysctl' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to have_sysctl_resource_count(0) }
      end

      context "with settings => { 'vm.overcommit_memory' => { 'value' => '1'}, 'vm.max_map_count => { 'value' => '262144', 'persist' => false } }" do
        let(:params) {
          {
            'settings' => {
              'vm.overcommit_memory' => { 'value' => '1' },
              'vm.max_map_count' => { 'value' => '262144', 'persist' => false }
            }
          }
        }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_sysctl('vm.overcommit_memory').with(
          'value' => '1'
          )
        }

        it { is_expected.to contain_sysctl('vm.max_map_count').with(
          'value'   => '262144',
          'persist' => false
          )
        }
      end
    end
  end
end
