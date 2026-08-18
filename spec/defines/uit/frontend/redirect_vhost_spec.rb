describe 'profiles::uit::frontend::redirect_vhost' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:hiera_config) { 'spec/support/hiera/common.yaml' }

      context 'with title => foo.example.com' do
        let(:title) { 'foo.example.com' }

        context 'with redirect_url => https://destination.example.com' do
          let(:params) { {
            'redirect_url' => 'https://destination.example.com'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__uit__frontend__redirect_vhost('foo.example.com').with(
            'redirect_url'    => 'https://destination.example.com',
            'redirect_source' => [],
            'serveraliases'   => []
          ) }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://foo.example.com').with(
            'serveraliases'  => [],
            'rewrites'       => [{
                                  'comment'      => 'Provide environment variable REDIRECT_URL to rewrite rules',
                                  'rewrite_rule' => '^ - [E=REDIRECT_URL:https://destination.example.com]'
                                }]
          ) }
        end
      end

      context 'with title => michelangelo.example.com' do
        let(:title) { 'michelangelo.example.com' }

        context 'with redirect_url => https://mydest.example.com, redirect_source => [{ comment => Provide environment variable URL_PARAMS to rewrite rules, rewrite_rule => ^ - [E=URL_PARAMS:utm_campaign=redirect&utm_medium=migration] }, { comment => Redirect homepage, rewrite_cond => %{REQUEST_URI} ^/(.*)$ [NC], rewrite_rule => ^ %{ENV:REDIRECT_URL}/agenda?%{ENV:URL_PARAMS} [L,R=301,B] }] and serveraliases => [mich.example.com, angelo.example.com]' do
          let(:params) { {
            'redirect_url'    => 'https://mydest.example.com',
            'redirect_source' => [{
                                   'comment'      => 'Provide environment variable URL_PARAMS to rewrite rules',
                                   'rewrite_rule' => '^ - [E=URL_PARAMS:utm_campaign=redirect&utm_medium=migration]'
                                 }, {
                                   'comment'      => 'Redirect homepage',
                                   'rewrite_cond' => '%{REQUEST_URI} ^/(.*)$ [NC]',
                                   'rewrite_rule' => '^ %{ENV:REDIRECT_URL}/agenda?%{ENV:URL_PARAMS} [L,R=301,B]'
                                 }],
            'serveraliases'   => ['mich.example.com', 'angelo.example.com'],
          } }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://michelangelo.example.com').with(
            'serveraliases' => ['mich.example.com', 'angelo.example.com'],
            'rewrites'      => [{
                                 'comment'      => 'Provide environment variable REDIRECT_URL to rewrite rules',
                                 'rewrite_rule' => '^ - [E=REDIRECT_URL:https://mydest.example.com]'
                               }, {
                                 'comment'      => 'Provide environment variable URL_PARAMS to rewrite rules',
                                 'rewrite_rule' => '^ - [E=URL_PARAMS:utm_campaign=redirect&utm_medium=migration]'
                               }, {
                                 'comment'      => 'Redirect homepage',
                                 'rewrite_cond' => '%{REQUEST_URI} ^/(.*)$ [NC]',
                                 'rewrite_rule' => '^ %{ENV:REDIRECT_URL}/agenda?%{ENV:URL_PARAMS} [L,R=301,B]'
                               }]
          ) }
        end
      end

      context 'with title => leonardo.example.com' do
        let(:title) { 'leonardo.example.com' }

        context 'with redirect_url => http://buonarotti.example.com, redirect_source => { comment => Redirect homepage, rewrite_cond => %{REQUEST_URI} ^/(.*)$ [NC], rewrite_rule => ^ %{ENV:REDIRECT_URL}/agenda?%{ENV:URL_PARAMS} [L,R=301,B] } and serveraliases => davinci.example.com' do
          let(:params) { {
            'redirect_url'    => 'http://buonarotti.example.com',
            'redirect_source' => {
                                   'comment'      => 'Redirect homepage',
                                   'rewrite_cond' => '%{REQUEST_URI} ^/(.*)$ [NC]',
                                   'rewrite_rule' => '^ %{ENV:REDIRECT_URL}/agenda [L,R=301,B]'
                                 },
            'serveraliases'   => 'davinci.example.com'
          } }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://leonardo.example.com').with(
            'serveraliases'  => ['davinci.example.com'],
            'rewrites'       => [{
                                  'comment'      => 'Provide environment variable REDIRECT_URL to rewrite rules',
                                  'rewrite_rule' => '^ - [E=REDIRECT_URL:http://buonarotti.example.com]'
                                }, {
                                  'comment'      => 'Redirect homepage',
                                  'rewrite_cond' => '%{REQUEST_URI} ^/(.*)$ [NC]',
                                  'rewrite_rule' => '^ %{ENV:REDIRECT_URL}/agenda [L,R=301,B]'
                                }]
          ) }
        end

        context "without parameters" do
          let(:params) { {} }

          it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'redirect_url'/) }
        end
      end
    end
  end
end
