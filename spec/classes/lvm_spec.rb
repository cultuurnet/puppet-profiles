describe 'profiles::lvm' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::lvm').with(
          'volume_groups' => {}
        ) }

        it { is_expected.to contain_apt__source('publiq-tools') }
        it { is_expected.to contain_package('amazon-ec2-utils').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_exec('amazon-ec2-utils-udevadm-trigger').with(
          'command'     => 'udevadm trigger /dev/nvme* && sleep 5',
          'path'        => ['/usr/sbin', '/usr/bin'],
          'refreshonly' => true,
          'logoutput'   => 'on_failure',
          'onlyif'      => 'ebsnvme-id /dev/nvme0'
        ) }

        it { is_expected.to contain_class('lvm').with(
          'manage_pkg' => true
        ) }

        it { is_expected.to contain_file('/data').with(
          'ensure' => 'directory',
          'group'  => 'root',
          'mode'   => '0755',
          'owner'  => 'root'
        ) }

        it { is_expected.to have_physical_volume_resource_count(0) }
        it { is_expected.to have_volume_group_resource_count(0) }

        it { is_expected.to contain_package('amazon-ec2-utils').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_package('amazon-ec2-utils').that_notifies('Exec[amazon-ec2-utils-udevadm-trigger]') }
        it { is_expected.to contain_exec('amazon-ec2-utils-udevadm-trigger').that_comes_before('Class[lvm]') }
      end

      context "with volume_groups => { datavg => { physical_volumes => '/dev/xvdb' } }" do
        let(:params) { {
          'volume_groups' => { 'datavg' => { 'physical_volumes' => '/dev/xvdb' }}
        } }

        it { is_expected.to contain_physical_volume('/dev/xvdb').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('datavg').with(
          'ensure'           => 'present',
          'physical_volumes' => '/dev/xvdb'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdb').that_requires('Class[lvm]') }
        it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Volume_group[datavg]') }

        context "with terraform provided volume size for xvdb set to 60g" do
          let(:hiera_config) { 'spec/support/hiera/terraform_available.yaml' }

          context "with physical extent count for /dev/xvdb being 15359" do
            let(:facts) {
              facts.merge( {
                'physical_volumes' => { '/dev/xvdb' => { 'pe_count' => '15359' } }
              } )
            }

            it { is_expected.not_to contain_exec('resize physical volume /dev/xvdb') }
          end

          context "with physical extent count for /dev/xvdb being 10000" do
            let(:facts) {
              facts.merge( {
                'physical_volumes' => { '/dev/xvdb' => { 'pe_count' => '10000' } }
              } )
            }

            it { is_expected.to contain_exec('resize_pv_/dev/xvdb').with(
              'command' => 'pvresize /dev/xvdb',
              'path'    => ['/usr/sbin', '/usr/bin']
            ) }

            it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Exec[resize_pv_/dev/xvdb]') }
          end
        end

        context "without terraform provided volume size for xvdb" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.not_to contain_exec('resize physical volume /dev/xvdb') }
        end
      end

      context "with volume_groups => { data1vg => { physical_volumes => '/dev/xvdb' }, data2vg => { physical_volumes => [ '/dev/xvdc', '/dev/xvdd'] }}" do
        let(:params) { {
          'volume_groups' => {
                               'data1vg' => { 'physical_volumes' => '/dev/xvdb' },
                               'data2vg' => { 'physical_volumes' => ['/dev/xvdc', '/dev/xvdd'] }
                             }
        } }

        it { is_expected.to contain_physical_volume('/dev/xvdb').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdc').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdd').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_volume_group('data1vg').with(
          'ensure'           => 'present',
          'physical_volumes' => '/dev/xvdb'
        ) }

        it { is_expected.to contain_volume_group('data2vg').with(
          'ensure'           => 'present',
          'physical_volumes' => ['/dev/xvdc', '/dev/xvdd']
        ) }

        it { is_expected.to contain_physical_volume('/dev/xvdb').that_requires('Class[lvm]') }
        it { is_expected.to contain_physical_volume('/dev/xvdc').that_requires('Class[lvm]') }
        it { is_expected.to contain_physical_volume('/dev/xvdd').that_requires('Class[lvm]') }
        it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Volume_group[data1vg]') }
        it { is_expected.to contain_physical_volume('/dev/xvdc').that_comes_before('Volume_group[data2vg]') }
        it { is_expected.to contain_physical_volume('/dev/xvdd').that_comes_before('Volume_group[data2vg]') }

        context "with terraform provided volume size for xvdb set to 60g, for xvdc to 40g and for xvdd to 20g" do
          let(:hiera_config) { 'spec/support/hiera/terraform_available.yaml' }

          context "with physical extent count for /dev/xdvb being 15359, for /dev/xvdc being  and for /dev/xvdd being " do
            let(:facts) {
              facts.merge( {
                'physical_volumes' => {
                  '/dev/xvdb' => { 'pe_count' => '15359' },
                  '/dev/xvdc' => { 'pe_count' => '10239' },
                  '/dev/xvdd' => { 'pe_count' => '5119' }
                }
              } )
            }

            it { is_expected.not_to contain_exec('resize physical volume /dev/xvdb') }
            it { is_expected.not_to contain_exec('resize physical volume /dev/xvdc') }
            it { is_expected.not_to contain_exec('resize physical volume /dev/xvdd') }
          end

          context "with physical extent count for /dev/xvdb being 10000, for /dev/xvdc being 5000 and for /dev/xvdd being 3000" do
            let(:facts) {
              facts.merge( {
                'physical_volumes' => {
                  '/dev/xvdb' => { 'pe_count' => '10000' },
                  '/dev/xvdc' => { 'pe_count' => '5000' },
                  '/dev/xvdd' => { 'pe_count' => '3000' }
                }
              } )
            }

            it { is_expected.to contain_exec('resize_pv_/dev/xvdb').with(
              'command' => 'pvresize /dev/xvdb',
              'path'    => ['/usr/sbin', '/usr/bin']
            ) }

            it { is_expected.to contain_exec('resize_pv_/dev/xvdc').with(
              'command' => 'pvresize /dev/xvdc',
              'path'    => ['/usr/sbin', '/usr/bin']
            ) }

            it { is_expected.to contain_exec('resize_pv_/dev/xvdd').with(
              'command' => 'pvresize /dev/xvdd',
              'path'    => ['/usr/sbin', '/usr/bin']
            ) }

            it { is_expected.to contain_physical_volume('/dev/xvdb').that_comes_before('Exec[resize_pv_/dev/xvdb]') }
            it { is_expected.to contain_physical_volume('/dev/xvdc').that_comes_before('Exec[resize_pv_/dev/xvdc]') }
            it { is_expected.to contain_physical_volume('/dev/xvdd').that_comes_before('Exec[resize_pv_/dev/xvdd]') }
          end
        end

        context "without terraform provided volume size for xvdb" do
          let(:hiera_config) { 'spec/support/hiera/empty.yaml' }

          it { is_expected.not_to contain_exec('resize physical volume /dev/xvdb') }
        end
      end
    end
  end
end
