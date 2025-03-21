describe 'profiles::puppet::puppetserver' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "on host aaa.example.com" do
        let(:node) { 'aaa.example.com' }

        context "without parameters" do
          let(:params) { {} }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetserver').with(
            'version'                => 'installed',
            'dns_alt_names'          => nil,
            'autosign'               => false,
            'trusted_amis'           => [],
            'trusted_certnames'      => [],
            'eyaml'                  => false,
            'eyaml_gpg_key'          => {},
            'lookup_hierarchy'       => [
                                          { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                          { 'name' => 'Common data', 'path' => 'common.yaml' }
                                        ],
            'vault_integration'      => false,
            'vault_address'          => nil,
            'vault_mounts'           => {},
            'terraform_integration'  => false,
            'terraform_bucket'       => nil,
            'terraform_use_iam_role' => true,
            'puppetdb_url'           => nil,
            'puppetdb_version'       => nil,
            'initial_heap_size'      => nil,
            'maximum_heap_size'      => nil,
            'report_retention_days'  => 0,
            'service_status'         => 'running'
          ) }

          it { is_expected.to contain_firewall('300 accept puppetserver HTTPS traffic') }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::install').with(
            'version' => 'installed'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver ca_server').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'ca_server',
            'value'   => 'aaa.example.com'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'absent',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver environmentpath').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'environmentpath',
            'value'   => '$codedir/environments'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver environment_timeout').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'environment_timeout',
            'value'   => 'unlimited'
          ) }

          it { is_expected.to contain_puppet_authorization__rule('puppetserver environment cache').with(
            'ensure'               => 'present',
            'path'                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
            'match_request_path'   => '/puppet-admin-api/v1/environment-cache',
            'match_request_type'   => 'path',
            'match_request_method' => 'delete',
            'allow'                => '*',
            'sort_order'           => 200
          ) }

          it { is_expected.to contain_hocon_setting('puppetserver ca allow-subject-alt-names').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetserver/conf.d/ca.conf',
            'setting' => 'certificate-authority.allow-subject-alt-names',
            'type'    => 'boolean',
            'value'   => true
          ) }

          it { is_expected.to contain_hocon_setting('puppetserver dropsonde').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf',
            'setting' => 'dropsonde.enabled',
            'type'    => 'boolean',
            'value'   => false
          ) }

          it { is_expected.to contain_file('puppetserver dropsonde directory').with(
            'path'    => '/opt/puppetlabs/server/data/puppetserver/dropsonde',
            'owner'   => 'puppet',
            'group'   => 'puppet'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::service').with(
            'status' => 'running'
          ) }

          it { is_expected.not_to contain_augeas('puppetserver_initial_heap_size') }
          it { is_expected.not_to contain_augeas('puppetserver_maximum_heap_size') }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
            'autosign'          => false,
            'trusted_amis'      => [],
            'trusted_certnames' => []
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').with(
            'eyaml'                 => false,
            'gpg_key'               => {},
            'terraform_integration' => false
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').with(
            'url'     => nil,
            'version' => nil
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::vault') }

          it { is_expected.not_to contain_class('profiles::puppet::puppetserver::terraform') }

          it { is_expected.to contain_cron('puppetserver_report_retention').with(
            'environment' => [ 'MAILTO=infra+cron@publiq.be'],
            'command'     => '/usr/bin/find /opt/puppetlabs/server/data/puppetserver/reports -type f -name "*.yaml" -mtime +0 -exec rm {} \;',
            'hour'        => '0',
            'minute'      => '0'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::install').that_requires('Ini_setting[puppetserver ca_server]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::install').that_requires('Ini_setting[puppetserver dns_alt_names]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::install').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_ini_setting('puppetserver ca_server').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_ini_setting('puppetserver environmentpath').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_ini_setting('puppetserver environment_timeout').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_puppet_authorization__rule('puppetserver environment cache').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_file('puppetserver dropsonde directory').that_requires('Group[puppet]') }
          it { is_expected.to contain_file('puppetserver dropsonde directory').that_requires('User[puppet]') }
          it { is_expected.to contain_file('puppetserver dropsonde directory').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_file('puppetserver dropsonde directory').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_hocon_setting('puppetserver dropsonde').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_hocon_setting('puppetserver dropsonde').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_hocon_setting('puppetserver ca allow-subject-alt-names').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_hocon_setting('puppetserver ca allow-subject-alt-names').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::vault').that_comes_before('Class[profiles::puppet::puppetserver::hiera]') }

          context 'with Terraform and Vault integration enabled and data available' do
            let(:hiera_config) { 'spec/support/hiera/terraform_common.yaml' }

            context 'with vault_integration => true, vault_address => https://vault.example.com:8200, vault_mounts => { foo => [bar, baz] } and terraform_bucket => mybucket' do
              let(:params) {
                super().merge( {
                  'vault_integration' => true,
                  'vault_address'     => 'https://vault.example.com:8200',
                  'vault_mounts'      => { 'foo' => ['bar', 'baz'] },
                  'terraform_bucket'  => 'mybucket'
                } )
              }

              it { is_expected.to compile.with_all_deps }

              it { is_expected.to contain_class('profiles::puppet::puppetserver').with(
                'version'                => 'installed',
                'dns_alt_names'          => nil,
                'autosign'               => false,
                'trusted_amis'           => [],
                'trusted_certnames'      => [],
                'eyaml'                  => false,
                'eyaml_gpg_key'          => {},
                'lookup_hierarchy'       => [
                                              { 'name' => 'Per-node data', 'path' => 'nodes/%{::trusted.certname}.yaml' },
                                              { 'name' => 'Common data', 'path' => 'common.yaml' }
                                            ],
                'vault_integration'      => true,
                'vault_address'          => 'https://vault.example.com:8200',
                'vault_mounts'           => { 'foo' => ['bar', 'baz'] },
                'terraform_integration'  => true,
                'terraform_bucket'       => 'mybucket',
                'terraform_use_iam_role' => true,
                'puppetdb_url'           => nil,
                'puppetdb_version'       => nil,
                'initial_heap_size'      => nil,
                'maximum_heap_size'      => nil,
                'report_retention_days'  => 0,
                'service_status'         => 'running'
              ) }

              it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').with(
                'eyaml'                 => false,
                'gpg_key'               => {},
                'terraform_integration' => true,
                'vault_integration'     => true,
                'vault_address'         => 'https://vault.example.com:8200',
                'vault_mounts'          => { 'foo' => ['bar', 'baz'] },
              ) }

              it { is_expected.to contain_class('profiles::puppet::puppetserver::vault') }

              it { is_expected.to contain_class('profiles::puppet::puppetserver::terraform').with(
                'bucket'       => 'mybucket',
                'use_iam_role' => true
              ) }

              it { is_expected.to contain_class('profiles::puppet::puppetserver::vault').that_comes_before('Class[profiles::puppet::puppetserver::hiera]') }
              it { is_expected.to contain_class('profiles::puppet::puppetserver::vault').that_notifies('Class[profiles::puppet::puppetserver::service]') }
            end
          end
        end

        context "with version => 1.2.3, dns_alt_names => puppet.services.example.com, autosign => true, trusted_amis => ami-123, trusted_certnames => [], eyaml => true, eyaml_gpg_key => { 'id' => '6789DEFD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\neyamlkey\n-----END PGP PRIVATE KEY BLOCK-----' }, lookup_hierarchy => { name => Common data, path => common.yaml }, terraform_integration => true, terraform_bucket => mybucket, puppetdb_url => https://puppetdb.example.com:8081, initial_heap_size => 512m, maximum_heap_size => 512m, report_retention_days => 5 and service_status => stopped" do
          let(:params) { {
            'version'               => '1.2.3',
            'dns_alt_names'         => 'puppet.services.example.com',
            'autosign'              => true,
            'trusted_amis'          => 'ami-123',
            'trusted_certnames'     => [],
            'eyaml'                 => true,
            'eyaml_gpg_key'         => {
                                         'id'      => '6789DEFD',
                                         'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\neyamlkey\n-----END PGP PRIVATE KEY BLOCK-----"
                                       },
            'lookup_hierarchy'      => { 'name' => 'Common data', 'path' => 'common.yaml' },
            'terraform_integration' => true,
            'terraform_bucket'      => 'mybucket',
            'puppetdb_url'          => 'https://puppetdb.example.com:8081',
            'initial_heap_size'     => '512m',
            'maximum_heap_size'     => '512m',
            'report_retention_days' => 5,
            'service_status'        => 'stopped'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::install').with(
            'version' => '1.2.3'
          ) }

          it { is_expected.to contain_augeas('puppetserver_initial_heap_size').with(
            'lens'    => 'Shellvars_list.lns',
            'incl'    => '/etc/default/puppetserver',
            'context' => '/files/etc/default/puppetserver/JAVA_ARGS',
            'changes' => "set value[. =~ regexp('-Xms.*')] '-Xms512m'"
          ) }

          it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').with(
            'lens'    => 'Shellvars_list.lns',
            'incl'    => '/etc/default/puppetserver',
            'context' => '/files/etc/default/puppetserver/JAVA_ARGS',
            'changes' => "set value[. =~ regexp('-Xmx.*')] '-Xmx512m'"
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names',
            'value'   => 'puppet.services.example.com'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
            'autosign'          => true,
            'trusted_certnames' => [],
            'trusted_amis'      => 'ami-123'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').with(
            'eyaml'                 => true,
            'terraform_integration' => true,
            'gpg_key'               => {
                                         'id'      => '6789DEFD',
                                         'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\neyamlkey\n-----END PGP PRIVATE KEY BLOCK-----"
                                       },
            'lookup_hierarchy'      => { 'name' => 'Common data', 'path' => 'common.yaml' }
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::terraform').with(
            'bucket'       => 'mybucket',
            'use_iam_role' => true
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').with(
            'url'     => 'https://puppetdb.example.com:8081',
            'version' => nil
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::service').with(
            'status' => 'stopped'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').that_comes_before('Class[profiles::puppet::puppetserver::terraform]') }

          it { is_expected.to contain_cron('puppetserver_report_retention').with(
            'environment' => [ 'MAILTO=infra+cron@publiq.be'],
            'command'     => '/usr/bin/find /opt/puppetlabs/server/data/puppetserver/reports -type f -name "*.yaml" -mtime +4 -exec rm {} \;',
            'hour'        => '0',
            'minute'      => '0'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::terraform').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_augeas('puppetserver_initial_heap_size').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_augeas('puppetserver_initial_heap_size').that_notifies('Class[profiles::puppet::puppetserver::service]') }
          it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').that_requires('Class[profiles::puppet::puppetserver::install]') }
          it { is_expected.to contain_augeas('puppetserver_maximum_heap_size').that_notifies('Class[profiles::puppet::puppetserver::service]') }
        end
      end

      context "on host bbb.example.com" do
        let(:node) { 'bbb.example.com' }

        context "with autosign => true, trusted_amis => [], trusted_certnames => [a.example.com, b.example.com, *.c.example.com], eyaml => true, eyaml_gpg_key => { 'id' => '1234ABCD', 'content' => '-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----' }, terraform_integration => true, terraform_bucket => foobar, terraform_use_iam_role => false, vault_integration => true, vault_address => https://localhost:8443, vault_mounts => { 'snafu' => ['foo', 'bar'], 'test' => ['baz', 'bla'] }, puppetdb_url => https://foo.example.com:1234, puppetdb_version => 7.8.9 and dns_alt_names => [puppet1.services.example.com, puppet2.services.example.com]" do
          let(:params) { {
            'autosign'               => true,
            'trusted_amis'           => [],
            'trusted_certnames'      => ['a.example.com', 'b.example.com', '*.c.example.com'],
            'eyaml'                  => true,
            'eyaml_gpg_key'          => {
                                          'id'      => '1234ABCD',
                                          'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----"
                                        },
            'terraform_integration'  => true,
            'terraform_bucket'       => 'foobar',
            'terraform_use_iam_role' => false,
            'vault_integration'      => true,
            'vault_address'          => 'https://localhost:8443',
            'vault_mounts'           => { 'snafu' => ['foo', 'bar'], 'test' => ['baz', 'bla'] },
            'puppetdb_url'           => 'https://foo.example.com:1234',
            'puppetdb_version'       => '7.8.9',
            'dns_alt_names'          => ['puppet1.services.example.com', 'puppet2.services.example.com'],
          } }

          it { is_expected.to contain_ini_setting('puppetserver ca_server').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'ca_server',
            'value'   => 'bbb.example.com'
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
            'autosign'          => true,
            'trusted_amis'      => [],
            'trusted_certnames' => ['a.example.com', 'b.example.com', '*.c.example.com'],
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::hiera').with(
            'eyaml'                 => true,
            'terraform_integration' => true,
            'vault_integration'     => true,
            'gpg_key'               => {
                                         'id'      => '1234ABCD',
                                         'content' => "-----BEGIN PGP PRIVATE KEY BLOCK-----\nfoobar\n-----END PGP PRIVATE KEY BLOCK-----"
                                       }
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::terraform').with(
            'bucket'       => 'foobar',
            'use_iam_role' => false
          ) }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::vault') }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::puppetdb').with(
            'url'     => 'https://foo.example.com:1234',
            'version' => '7.8.9'
          ) }

          it { is_expected.to contain_ini_setting('puppetserver dns_alt_names').with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppet/puppet.conf',
            'section' => 'server',
            'setting' => 'dns_alt_names',
            'value'   => 'puppet1.services.example.com,puppet2.services.example.com'
          ) }
        end

        context "with autosign => true and trusted_amis => ['ami-234', 'ami-567']" do
          let(:params) { {
            'autosign'     => true,
            'trusted_amis' => ['ami-234', 'ami-567']
          } }

          it { is_expected.to contain_class('profiles::puppet::puppetserver::autosign').with(
            'autosign'          => true,
            'trusted_amis'      => ['ami-234', 'ami-567'],
            'trusted_certnames' => []
          ) }
        end

        context "with autosign => true, trusted_certnames => [a.example.com, b.example.com, *.c.example.com] and trusted_amis => ['ami-234', 'ami-567']" do
          let(:params) { {
            'autosign'          => true,
            'trusted_amis'      => ['ami-234', 'ami-567'],
            'trusted_certnames' => ['a.example.com', 'b.example.com', '*.c.example.com'],
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects either a value for parameter 'trusted_amis' or 'trusted_certnames' when autosigning/) }
        end

        context "with eyaml => true and eyaml_gpg_key => {}" do
          let(:params) { {
            'eyaml'         => true,
            'eyaml_gpg_key' => {}
          } }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a non-empty value for parameter 'gpg_key' when eyaml is enabled/) }
        end
      end
    end
  end
end
