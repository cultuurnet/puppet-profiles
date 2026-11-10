describe 'profiles::media::rewrite' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with title => images.example.com' do
        let(:title) { 'images.example.com' }

        context 'with forwardingurl => https://images.imgix.net' do
          let(:params) { {
            'forwardingurl' => 'https://images.imgix.net'
          } }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_profiles__apache__vhost__basic('http://images.example.com').with(
            'documentroot'  => '/var/www',
            'serveraliases' => []
          ) }

          it { expect(catalogue.resource('Profiles::Apache::Vhost::Basic', 'http://images.example.com')['rewrites']).to(
            include(
              {
                'comment'      => 'Remove the AI generated marker from the file name, the stored file has no marker, and add the AI watermark',
                'rewrite_cond' => '%{ENV:IMGIX_REQUEST_URI} ^(.*)\.ai\.([^./]+)$',
                'rewrite_rule' => '^ - [E=IMGIX_REQUEST_URI:%1.%2,E=WATERMARK:]'
              },
              {
                'comment'      => 'Create forwarding rule to image service',
                'rewrite_rule' => '^/(.*)$ https://images.imgix.net%{ENV:IMGIX_REQUEST_URI}?auto=compress&auto=format&%{ENV:WIDTH}%{ENV:HEIGHT}%{ENV:CROP}%{ENV:RECT}%{ENV:FORMAT}%{ENV:FLIP}%{ENV:ROTATE}%{ENV:PAD}%{ENV:FIT}%{ENV:BGCOLOR}%{ENV:WATERMARK} [R=301,L]'
              }
            )
          ) }
        end

        context 'with forwardingurl => https://images.imgix.net and ai_watermark => https://images.imgix.net/ai-logo.png' do
          let(:params) { {
            'forwardingurl' => 'https://images.imgix.net',
            'ai_watermark'  => 'https://images.imgix.net/ai-logo.png'
          } }

          it { is_expected.to compile.with_all_deps }

          it { expect(catalogue.resource('Profiles::Apache::Vhost::Basic', 'http://images.example.com')['rewrites']).to(
            include(
              {
                'comment'      => 'Remove the AI generated marker from the file name, the stored file has no marker, and add the AI watermark',
                'rewrite_cond' => '%{ENV:IMGIX_REQUEST_URI} ^(.*)\.ai\.([^./]+)$',
                'rewrite_rule' => '^ - [E=IMGIX_REQUEST_URI:%1.%2,E=WATERMARK:mark64=aHR0cHM6Ly9pbWFnZXMuaW1naXgubmV0L2FpLWxvZ28ucG5n&mark-w=50&mark-h=56&mark-x=15&mark-y=9&mark-fit=clip&]'
              }
            )
          ) }
        end
      end
    end
  end
end
