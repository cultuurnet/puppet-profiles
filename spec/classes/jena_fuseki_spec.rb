describe 'profiles::jena_fuseki' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jena_fuseki').with(
          'version'          => 'installed',
          'port'             => 3030,
          'jvm_args'         => '-Xmx1G',
          'query_timeout_ms' => '5000',
          'datasets'         => {},
          'lvm'              => false,
          'volume_group'     => nil,
          'volume_size'      => nil
        ) }

        it { is_expected.to contain_group('fuseki') }
        it { is_expected.to contain_user('fuseki') }

        it { is_expected.to contain_class('profiles::java') }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('jena-fuseki').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_file('jena-fuseki config').with(
          'ensure'  => 'file',
          'path'    => '/etc/jena-fuseki/config.ttl',
          'content' => nil
        ) }

        it { is_expected.to contain_file('jena-fuseki service defaults').with(
          'ensure' => 'file',
          'path'   => '/etc/default/jena-fuseki'
        ) }

        it { is_expected.to contain_shellvar('jena-fuseki PORT').with(
          'ensure'   => 'present',
          'variable' => 'PORT',
          'target'   => '/etc/default/jena-fuseki',
          'value'    => 3030
        ) }

        it { is_expected.to contain_shellvar('jena-fuseki JVM_ARGS').with(
          'ensure'   => 'present',
          'variable' => 'JVM_ARGS',
          'target'   => '/etc/default/jena-fuseki',
          'value'    => '-Xmx1G'
        ) }

        it { is_expected.to contain_shellvar('jena-fuseki QUERY_TIMEOUT_MS').with(
          'ensure'   => 'present',
          'variable' => 'QUERY_TIMEOUT_MS',
          'target'   => '/etc/default/jena-fuseki',
          'value'    => 5000
        ) }

        it { is_expected.to contain_service('jena-fuseki').with(
          'ensure' => 'running',
          'enable' => true,
          'hasstatus' => true
        ) }

        it { is_expected.to contain_group('fuseki').that_comes_before('Package[jena-fuseki]') }
        it { is_expected.to contain_user('fuseki').that_comes_before('Package[jena-fuseki]') }
        it { is_expected.to contain_apt__source('publiq-tools').that_comes_before('Package[jena-fuseki]') }
        it { is_expected.to contain_package('jena-fuseki').that_requires('Class[profiles::java]') }
        it { is_expected.to contain_file('jena-fuseki config').that_requires('Package[jena-fuseki]') }
        it { is_expected.to contain_service('jena-fuseki').that_subscribes_to('Package[jena-fuseki]') }
        it { is_expected.to contain_service('jena-fuseki').that_subscribes_to('File[jena-fuseki config]') }
        it { is_expected.to contain_service('jena-fuseki').that_subscribes_to('File[jena-fuseki service defaults]') }
        it { is_expected.to contain_shellvar('jena-fuseki PORT').that_requires('File[jena-fuseki service defaults]') }
        it { is_expected.to contain_shellvar('jena-fuseki JVM_ARGS').that_requires('File[jena-fuseki service defaults]') }
        it { is_expected.to contain_shellvar('jena-fuseki QUERY_TIMEOUT_MS').that_requires('File[jena-fuseki service defaults]') }
        it { is_expected.to contain_shellvar('jena-fuseki PORT').that_notifies('Service[jena-fuseki]') }
        it { is_expected.to contain_shellvar('jena-fuseki JVM_ARGS').that_notifies('Service[jena-fuseki]') }
        it { is_expected.to contain_shellvar('jena-fuseki QUERY_TIMEOUT_MS').that_notifies('Service[jena-fuseki]') }
      end

      context "with volume_group datavg present" do
        let(:pre_condition) { 'volume_group { "datavg": ensure => "present" }' }

        context "with version => 1.2.3, port => 13030, jvm_args => -Xms2G -Xmx4G, query_timeout_ms => 10000, datasets => { mydataset => { endpoint => myendpoint, union_default_graph => true }}, lvm => true, volume_group => datavg and volume_size => 50G" do
          let(:params) { {
            'version'          => '1.2.3',
            'port'             => 13030,
            'jvm_args'         => '-Xms2G -Xmx4G',
            'query_timeout_ms' => 10000,
            'datasets'         => { 'mydataset' => { 'endpoint' => '/myendpoint', 'union_default_graph' => true }},
            'lvm'              => true,
            'volume_group'     => 'datavg',
            'volume_size'      => '50G'
          } }

          it { is_expected.to contain_package('jena-fuseki').with(
            'ensure' => '1.2.3'
          ) }

          it { is_expected.to contain_shellvar('jena-fuseki PORT').with(
            'variable' => 'PORT',
            'value'    => 13030
          ) }

          it { is_expected.to contain_shellvar('jena-fuseki JVM_ARGS').with(
            'variable' => 'JVM_ARGS',
            'value'    => '-Xms2G -Xmx4G'
          ) }

          it { is_expected.to contain_shellvar('jena-fuseki QUERY_TIMEOUT_MS').with(
            'variable' => 'QUERY_TIMEOUT_MS',
            'value'    => 10000
          ) }

          it { is_expected.to contain_profiles__lvm__mount('rdfdata').with(
            'volume_group' => 'datavg',
            'size'         => '50G',
            'fs_type'      => 'ext4',
            'mountpoint'   => '/data/jena-fuseki/databases',
            'owner'        => 'fuseki',
            'group'        => 'fuseki'
          ) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki').with(
            'ensure' => 'directory',
            'owner'  => 'fuseki',
            'group'  => 'fuseki'
          ) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases').with(
            'ensure' => 'link',
            'target' => '/data/jena-fuseki/databases',
            'force'  => true,
            'owner'  => 'fuseki',
            'group'  => 'fuseki'
          ) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/mydataset').with(
            'ensure' => 'directory',
            'owner'  => 'fuseki',
            'group'  => 'fuseki'
          ) }

          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#mydataset_service_tdb_all> rdf:type fuseki:Service ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*rdfs:label\s*"TDB2 mydataset" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:name\s*"\/myendpoint" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:dataset\s*<#mydataset_dataset> ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#mydataset_dataset> rdf:type tdb2:DatasetTDB2 ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*tdb2:location\s*"\/var\/lib\/jena-fuseki\/databases\/mydataset" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*tdb2:unionDefaultGraph\s*true ;$/) }

          it { is_expected.to contain_group('fuseki').that_comes_before('Profiles::Lvm::Mount[rdfdata]') }
          it { is_expected.to contain_user('fuseki').that_comes_before('Profiles::Lvm::Mount[rdfdata]') }
          it { is_expected.to contain_profiles__lvm__mount('rdfdata').that_comes_before('Package[jena-fuseki]') }
          it { is_expected.to contain_file('/var/lib/jena-fuseki').that_comes_before('File[/var/lib/jena-fuseki/databases]') }
          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases').that_requires('Profiles::Lvm::Mount[rdfdata]') }
          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases').that_comes_before('Package[jena-fuseki]') }
          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/mydataset').that_comes_before('File[jena-fuseki config]') }
        end
      end

      context "with volume_group myvg present" do
        let(:pre_condition) { 'volume_group { "myvg": ensure => "present" }' }

        context "with datasets => { dataset1 => { endpoint => endpoint1 }, dataset2 => { endpoint => //endpoint2 }}, lvm => true, volume_group => myvg and volume_size => 10G" do
          let(:params) { {
            'datasets'     => {
                                'dataset1' => { 'endpoint' => 'endpoint1' },
                                'dataset2' => { 'endpoint' => '//endpoint2' }
                              },
            'lvm'          => true,
            'volume_group' => 'myvg',
            'volume_size'  => '10G'
          } }

          it { is_expected.to contain_profiles__lvm__mount('rdfdata').with(
            'volume_group' => 'myvg',
            'size'         => '10G',
            'mountpoint'   => '/data/jena-fuseki/databases',
            'owner'        => 'fuseki',
            'group'        => 'fuseki'
          ) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/dataset1').with(
            'ensure' => 'directory',
            'owner'  => 'fuseki',
            'group'  => 'fuseki'
          ) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/dataset2').with(
            'ensure' => 'directory',
            'owner'  => 'fuseki',
            'group'  => 'fuseki'
          ) }

          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#dataset1_service_tdb_all> rdf:type fuseki:Service ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*rdfs:label\s*"TDB2 dataset1" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:name\s*"\/endpoint1" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:dataset\s*<#dataset1_dataset> ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#dataset1_dataset> rdf:type tdb2:DatasetTDB2 ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*tdb2:location\s*"\/var\/lib\/jena-fuseki\/databases\/dataset1" ;$/) }
          it { is_expected.not_to contain_file('jena-fuseki config').with_content(/^\s*tdb2:unionDefaultGraph\s*.* ;$/) }

          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#dataset2_service_tdb_all> rdf:type fuseki:Service ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*rdfs:label\s*"TDB2 dataset2" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:name\s*"\/endpoint2" ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*fuseki:dataset\s*<#dataset2_dataset> ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^<#dataset2_dataset> rdf:type tdb2:DatasetTDB2 ;$/) }
          it { is_expected.to contain_file('jena-fuseki config').with_content(/^\s*tdb2:location\s*"\/var\/lib\/jena-fuseki\/databases\/dataset2" ;$/) }

          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/dataset1').that_comes_before('File[jena-fuseki config]') }
          it { is_expected.to contain_file('/var/lib/jena-fuseki/databases/dataset2').that_comes_before('File[jena-fuseki config]') }
        end
      end

      context "with lvm => true, volume_group => datavg" do
        let(:params) { {
          'lvm'          => true,
          'volume_group' => 'myvg'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end

      context "with lvm => true, volume_size => 100G" do
        let(:params) { {
          'lvm'         => true,
          'volume_size' => '100G'
        } }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /with LVM enabled, expects a value for both 'volume_group' and 'volume_size'/) }
      end
    end
  end
end
