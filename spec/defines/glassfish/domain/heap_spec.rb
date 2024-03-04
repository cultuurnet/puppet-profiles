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
        # (x) Parameter maximum (initial run)
        #       - Parameter maximum == default (512m)
        #       - Parameter maximum <> default (512m)
        # (x) Parameter initial (initial run)
        # (x) Parameters maximum & initial, no facts (initial run)
        #
        # Initial fact
        # (x) No parameters (subsequent runs)
        # (x) Parameter initial (subsequent runs)
        #   - Parameter initial == fact
        #   - Parameter initial <> fact
        # (x) Parameter maximum (subsequent runs)
        # (x) Parameters maximum & initial (subsequent runs)
        #   - Parameter initial == fact
        #   - Parameter initial <> fact
        #   - Parameter maximum == default
        #   - Parameter maximum <> default
        #
        # Maximum fact
        # (x) No parameters (subsequent runs)
        # (x) Parameter initial (subsequent runs)
        # (x) Parameter maximum (subsequent runs)
        #   - Parameter maximum == fact
        #   - Parameter maximum <> fact
        # (x) Parameters maximum & initial (subsequent runs)
        #   - Parameter maximum == fact
        #   - Parameter maximum <> fact
        #
        # Maximum & Initial fact
        # (x) No parameters (subsequent runs)
        #   - Fact maximum == default
        #   - Fact maximum <> default
        # (x) Parameter initial (subsequent runs)
        #   - Parameter initial == fact
        #   - Parameter initial <> fact
        #   - Fact maximum == default
        #   - Fact maximum <> default
        # (x) Parameter maximum (subsequent runs)
        #   - Parameter maximum == fact
        #   - Parameter maximum <> fact
        # Parameters maximum & initial (subsequent runs)
        #   - Parameter maximum & initial == fact
        #   - Parameter maximum <> fact
        #   - Parameter initial <> fact
        #   - Parameter maximum & initial <> fact

        context 'without heap facts' do
          let(:facts) { super().merge({}) }

          context 'without parameters' do
            let(:params) { {} }

            it { is_expected.to compile.with_all_deps }

            it { is_expected.to contain_profiles__glassfish__domain__heap('foobar-api').with(
              'initial'  => nil,
              'maximum'  => '512m',
              'portbase' => 4800
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with maximum => 512m' do
            let(:params) { {
              'maximum' => '512m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx512m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with maximum => 1024m' do
            let(:params) { {
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '1024m'$/) }
          end

          context 'with initial => 256m' do
            let(:params) { {
              'initial' => '256m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m and maximum => 512m' do
            let(:params) { {
              'initial' => '256m',
              'maximum' => '512m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m and maximum => 768m' do
            let(:params) { {
              'initial' => '256m',
              'maximum' => '768m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '768m'$/) }
          end
        end

        context 'with initial heap fact 384m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial' => '384m' } } } }
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with initial => 384m' do
            let(:params) { {
              'initial' => '384m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '384m'\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m' do
            let(:params) { {
              'initial' => '256m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
          end

          context 'with maximum => 1024m' do
            let(:params) { {
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '1024m'$/) }
          end

          context 'with initial => 384m and maximum => 1024m' do
            let(:params) { {
              'initial' => '384m',
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '384m'\n      maximum: '1024m'$/) }
          end

          context 'with initial => 512m and maximum => 1024m' do
            let(:params) { {
              'initial' => '512m',
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '512m'\n      maximum: '1024m'$/) }
          end

          context 'with initial => 512m and maximum => 512m' do
            let(:params) { {
              'initial' => '512m',
              'maximum' => '512m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '512m'\n      maximum: '512m'$/) }
          end
        end

        context 'with maximum heap fact 1024m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'maximum' => '1024m' } } } }
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m' do
            let(:params) { {
              'initial' => '256m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
          end

          context 'with maximum => 1024m' do
            let(:params) { {
              'maximum' => '1024m'
            } }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous initial heap jvmoption removal') }
            it { is_expected.not_to contain_jvmoption('Domain foobar-api initial heap jvmoption') }

            it { is_expected.not_to contain_jvmoption('Domain foobar-api previous maximum heap jvmoption removal') }

            it { is_expected.to contain_jvmoption('Domain foobar-api maximum heap jvmoption').with(
              'ensure' => 'present',
              'option' => '-Xmx1024m'
            ) }

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '1024m'$/) }
          end

          context 'with maximum => 1536m' do
            let(:params) { {
              'maximum' => '1536m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '1536m'$/) }
          end

          context 'with initial => 400m and maximum => 1024m' do
            let(:params) { {
              'initial' => '400m',
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '400m'\n      maximum: '1024m'$/) }
          end

          context 'with initial => 400m and maximum => 1536m' do
            let(:params) { {
              'initial' => '400m',
              'maximum' => '1536m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '400m'\n      maximum: '1536m'$/) }
          end
        end

        context 'with initial heap fact 256m and maximum heap fact 768m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial' => '256m', 'maximum' => '768m' } } } }
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with initial => 400m' do
            let(:params) { {
              'initial' => '400m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '400m'\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m' do
            let(:params) { {
              'initial' => '256m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
          end

          context 'with maximum => 1024m' do
            let(:params) { {
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '1024m'$/) }
          end

          context 'with maximum => 768m' do
            let(:params) { {
              'maximum' => '768m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '768m'$/) }
          end

          context 'with initial => 256m and maximum => 768m' do
            let(:params) { {
              'initial' => '256m',
              'maximum' => '768m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '768m'$/) }
          end

          context 'with initial => 512m and maximum => 768m' do
            let(:params) { {
              'initial' => '512m',
              'maximum' => '768m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '512m'\n      maximum: '768m'$/) }
          end

          context 'with initial => 256m and maximum => 1024m' do
            let(:params) { {
              'initial' => '256m',
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '1024m'$/) }
          end

          context 'with initial => 512m and maximum => 1024m' do
            let(:params) { {
              'initial' => '512m',
              'maximum' => '1024m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '512m'\n      maximum: '1024m'$/) }
          end
        end

        context 'with initial heap fact 256m and maximum heap fact 512m' do
          let(:facts) { super().merge(
            { 'glassfish' => { 'foobar-api' => { 'heap' => { 'initial' => '256m', 'maximum' => '512m' } } } }
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      maximum: '512m'$/) }
          end

          context 'with initial => 400m' do
            let(:params) { {
              'initial' => '400m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '400m'\n      maximum: '512m'$/) }
          end

          context 'with initial => 256m' do
            let(:params) { {
              'initial' => '256m'
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

            it { is_expected.to contain_file('Domain foobar-api heap external facts').with_content(/^---\nglassfish:\n  foobar-api:\n    heap:\n      initial: '256m'\n      maximum: '512m'$/) }
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

            it { is_expected.to contain_profiles__glassfish__domain__heap('baz-api').with(
              'initial'  => nil,
              'maximum'  => '512m',
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

            it { is_expected.to contain_file('Domain baz-api heap external facts').with_content(/^---\nglassfish:\n  baz-api:\n    heap:\n      maximum: '512m'$/) }
          end
        end
      end
    end
  end
end
