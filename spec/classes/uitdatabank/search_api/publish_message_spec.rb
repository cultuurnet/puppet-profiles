describe 'profiles::uitdatabank::search_api::publish_message' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::uitdatabank::search_api::publish_message').with(
          'version'           => 'present',
          'rabbitmq_host'     => nil,
          'rabbitmq_port'     => 5672,
          'rabbitmq_username' => nil,
          'rabbitmq_password' => nil,
          'rabbitmq_vhost'    => nil,
          'rabbitmq_exchange' => nil,
          'source_url'        => nil,
          'delay_ms'          => 0
        ) }

        it { is_expected.to contain_class('profiles::ruby') }

        it { is_expected.to contain_apt__source('publiq-tools') }

        it { is_expected.to contain_package('uitdatabank-publish-message').with(
          'ensure' => 'present'
        ) }

        it { is_expected.to contain_file('uitdatabank-publish-message.conf').with(
          'path' => '/etc/uitdatabank/publish-updated-message.conf'
        ) }

        it { is_expected.to contain_file('uitdatabank-publish-message.conf').with_content("RABBITMQ_PORT=5672\nDELAY_MS=0\n") }

        it { is_expected.to contain_package('uitdatabank-publish-message').that_requires('Apt::Source[publiq-tools]') }
        it { is_expected.to contain_file('uitdatabank-publish-message.conf').that_requires('Apt::Source[publiq-tools]') }
      end

      context 'with' do
        let(:params) { {
          'version'           => 'latest',
          'rabbitmq_host'     => 'myhost.example.com',
          'rabbitmq_port'     => 5673,
          'rabbitmq_username' => 'foo',
          'rabbitmq_password' => 'bar',
          'rabbitmq_vhost'    => 'baz',
          'rabbitmq_exchange' => 'snafu',
          'source_url'        => 'http://my.source.com',
          'delay_ms'          => 5
        } }

        it { is_expected.to contain_package('uitdatabank-publish-message').with(
          'ensure' => 'latest'
        ) }

        it { is_expected.to contain_file('uitdatabank-publish-message.conf').with_content("RABBITMQ_HOST=myhost.example.com\nRABBITMQ_PORT=5673\nRABBITMQ_USERNAME=foo\nRABBITMQ_PASSWORD=bar\nRABBITMQ_VHOST=baz\nRABBITMQ_EXCHANGE=snafu\nSOURCE_URL=http://my.source.com\nDELAY_MS=5\n") }
      end
    end
  end
end
