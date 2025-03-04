describe 'profiles::glassfish::domain::heap' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "title foobar-api" do
        let(:title) { 'foobar-api' }

        # Scenario's
        #
        # No facts (initial run)
        # (x) No parameters (initial run)
        # (x) Parameter maximum_size (initial run)
        #       - Parameter maximum_size == default (512m)
        #       - Parameter maximum_size <> default (512m)
        # (x) Parameter initial_size (initial run)
        # (x) Parameters maximum_size & initial_size, no facts (initial run)
        #
        # Initial fact
        # (x) No parameters (subsequent runs)
        # (x) Parameter initial_size (subsequent runs)
        #   - Parameter initial_size == fact
        #   - Parameter initial_size <> fact
        # (x) Parameter maximum_size (subsequent runs)
        # (x) Parameters maximum_size & initial_size (subsequent runs)
        #   - Parameter initial_size == fact
        #   - Parameter initial_size <> fact
        #   - Parameter maximum_size == default
        #   - Parameter maximum_size <> default
        #
        # Maximum fact
        # (x) No parameters (subsequent runs)
        # (x) Parameter initial_size (subsequent runs)
        # (x) Parameter maximum_size (subsequent runs)
        #   - Parameter maximum_size == fact
        #   - Parameter maximum_size <> fact
        # (x) Parameters maximum_size & initial_size (subsequent runs)
        #   - Parameter maximum_size == fact
        #   - Parameter maximum_size <> fact
        #
        # Maximum & Initial fact
        # (x) No parameters (subsequent runs)
        #   - Fact maximum_size == default
        #   - Fact maximum_size <> default
        # (x) Parameter initial_size (subsequent runs)
        #   - Parameter initial_size == fact
        #   - Parameter initial_size <> fact
        #   - Fact maximum_size == default
        #   - Fact maximum_size <> default
        # (x) Parameter maximum_size (subsequent runs)
        #   - Parameter maximum_size == fact
        #   - Parameter maximum_size <> fact
        # Parameters maximum_size & initial_size (subsequent runs)
        #   - Parameter maximum_size & initial_size == fact
        #   - Parameter maximum_size <> fact
        #   - Parameter initial_size <> fact
        #   - Parameter maximum_size & initial_size <> fact

        context 'without heap facts' do
          let(:facts) { super().merge({}) }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

            it { is_expected.to contain_profiles__glassfish__domain__heap('foobar-api').with(
              'initial_size' => nil,
              'maximum_size' => nil,
              'portbase'     => 4800
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with(
              'ensure' => 'file',
              'path'   => '/etc/puppetlabs/facter/facts.d/glassfish.foobar-api.heap.yaml'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').that_requires('File[/etc/puppetlabs/facter/facts.d]') }
          end

          context 'with maximum_size => 512m' do
            let(:params) { {
              'maximum_size' => '512m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }
          end

          context 'with maximum_size => 1024m' do
            let(:params) { {
              'maximum_size' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 256m' do
            let(:params) { {
              'initial_size' => '256m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m and maximum_size => 512m' do
            let(:params) { {
              'initial_size' => '256m',
              'maximum_size' => '512m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m and maximum_size => 768m' do
            let(:params) { {
              'initial_size' => '256m',
              'maximum_size' => '768m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '768m'$/) }
          end
        end

        context 'with initial_size heap fact 384m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial_size' => '384m' } } } }
          ) }

          context 'without parameters' do
            let(:params) { { } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms384m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 384m' do
            let(:params) { {
              'initial_size' => '384m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms384m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '384m'\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m' do
            let(:params) { {
              'initial_size' => '256m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms384m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end

          context 'with maximum_size => 1024m' do
            let(:params) { {
              'maximum_size' => '1024m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms384m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 384m and maximum_size => 1024m' do
            let(:params) { {
              'initial_size' => '384m',
              'maximum_size' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms384m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '384m'\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 512m and maximum_size => 1024m' do
            let(:params) { {
              'initial_size' => '512m',
              'maximum_size' => '1024m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms384m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '512m'\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 512m and maximum_size => 512m' do
            let(:params) { {
              'initial_size' => '512m',
              'maximum_size' => '512m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms384m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms512m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '512m'\n      maximum_size: '512m'$/) }
          end
        end

        context 'with maximum heap fact 1024m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'maximum_size' => '1024m' } } } }
          ) }

          context 'without parameters' do
            let(:params) { { } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m' do
            let(:params) { {
              'initial_size' => '256m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end

          context 'with maximum_size => 1024m' do
            let(:params) { {
              'maximum_size' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '1024m'$/) }
          end

          context 'with maximum_size => 1536m' do
            let(:params) { {
              'maximum_size' => '1536m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1536m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '1536m'$/) }
          end

          context 'with initial_size => 400m and maximum_size => 1024m' do
            let(:params) { {
              'initial_size' => '400m',
              'maximum_size' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms400m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '400m'\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 400m and maximum_size => 1536m' do
            let(:params) { {
              'initial_size' => '400m',
              'maximum_size' => '1536m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms400m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1536m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '400m'\n      maximum_size: '1536m'$/) }
          end
        end

        context 'with initial_size heap fact 256m and maximum heap fact 768m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial_size' => '256m', 'maximum_size' => '768m' } } } }
          ) }

          context 'without parameters' do
            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 400m' do
            let(:params) { {
              'initial_size' => '400m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms400m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '400m'\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m' do
            let(:params) { {
              'initial_size' => '256m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end

          context 'with maximum_size => 1024m' do
            let(:params) { {
              'maximum_size' => '1024m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '1024m'$/) }
          end

          context 'with maximum_size => 768m' do
            let(:params) { {
              'maximum_size' => '768m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '768m'$/) }
          end

          context 'with initial_size => 256m and maximum_size => 768m' do
            let(:params) { {
              'initial_size' => '256m',
              'maximum_size' => '768m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '768m'$/) }
          end

          context 'with initial_size => 512m and maximum_size => 768m' do
            let(:params) { {
              'initial_size' => '512m',
              'maximum_size' => '768m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms512m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '512m'\n      maximum_size: '768m'$/) }
          end

          context 'with initial_size => 256m and maximum_size => 1024m' do
            let(:params) { {
              'initial_size' => '256m',
              'maximum_size' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '1024m'$/) }
          end

          context 'with initial_size => 512m and maximum_size => 1024m' do
            let(:params) { {
              'initial_size' => '512m',
              'maximum_size' => '1024m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms512m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xmx768m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '512m'\n      maximum_size: '1024m'$/) }
          end
        end

        context 'with initial_size heap fact 256m and maximum_size heap fact 512m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial_size' => '256m', 'maximum_size' => '512m' } } } }
          ) }

          context 'without parameters' do
            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 400m' do
            let(:params) { {
              'initial_size' => '400m'
            } }

            it { is_expected.to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal').with(
              'ensure' => 'absent',
              'option' => '-Xms256m'
            ) }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms400m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '400m'\n      maximum_size: '512m'$/) }
          end

          context 'with initial_size => 256m' do
            let(:params) { {
              'initial_size' => '256m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api initial heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xms256m'
            ) }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial_size: '256m'\n      maximum_size: '512m'$/) }
          end
        end
      end

      context "title baz-api" do
        let(:title) { 'baz-api' }

        context 'without heap facts' do
          let(:facts) { super().merge({}) }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_file('/etc/puppetlabs/facter/facts.d') }

            it { is_expected.to contain_profiles__glassfish__domain__heap('baz-api').with(
              'initial'  => nil,
              'maximum'  => nil,
              'portbase' => 4800
            ) }

            it { is_expected.not_to contain_jvmoption('Domain baz-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain baz-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain baz-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain baz-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain baz-api heap external facts').with(
              'ensure' => 'file',
              'path'   => '/etc/puppetlabs/facter/facts.d/glassfish.baz-api.heap.yaml'
            ) }

            it { is_expected.to contain_file('Domain baz-api heap external facts').with_content(/^---\nglassfish:\n  baz-api:\n    heap:\n      maximum_size: '512m'$/) }

            it { is_expected.to contain_file('Domain baz-api heap external facts').that_requires('File[/etc/puppetlabs/facter/facts.d]') }
          end
        end
      end
    end
  end
end
