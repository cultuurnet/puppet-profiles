RSpec.shared_examples "UiTdatabank rabbitmq configuration" do |vhost, admin_user, admin_password|
  it { is_expected.to contain_rabbitmq_vhost("#{vhost}") }

  it { is_expected.to contain_rabbitmq_user_permissions("#{admin_user}@#{vhost}").with(
    'configure_permission' => '.*',
    'read_permission'      => '.*',
    'write_permission'     => '.*'
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("udb3.x.domain-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("rdf.q.udb3-domain-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@rdf.q.udb3-domain-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("uitpas.q.udb3-domain-events-api@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@uitpas.q.udb3-domain-events-api@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'api',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("uitpas.q.udb3-domain-events-cli@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@uitpas.q.udb3-domain-events-cli@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'cli',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("uitpas.q.udb3-domain-events-related@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@uitpas.q.udb3-domain-events-related@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'related',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("uitpas.x.uitpas-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("udb3.q.uitpas-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("uitpas.x.uitpas-events@udb3.q.uitpas-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("search.x.domain-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("search.q.udb3-domain-events-api@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@search.q.udb3-domain-events-api@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'api',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_binding("search.x.domain-events@search.q.udb3-domain-events-api@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'api',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("search.q.udb3-domain-events-cli@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@search.q.udb3-domain-events-cli@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'cli',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_binding("search.x.domain-events@search.q.udb3-domain-events-cli@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'cli',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("search.q.udb3-domain-events-related@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@search.q.udb3-domain-events-related@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'related',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_binding("search.x.domain-events@search.q.udb3-domain-events-related@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => 'related',
    'arguments'        => {}
    )
  }
end

describe 'profiles::uitdatabank::rabbitmq' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with vhost => 'foo', admin_user => 'bar' and admin_password => 'baz'" do
        let(:params) { {
          'vhost'          => 'foo',
          'admin_user'     => 'bar',
          'admin_password' => 'baz',
          'with_tools'     => true
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::rabbitmq').with(
          'admin_user'     => 'bar',
          'admin_password' => 'baz',
          'with_tools'     => true
          )
        }

        include_examples 'UiTdatabank rabbitmq configuration', 'foo', 'bar', 'baz'
      end

      context "with vhost => 'alice', admin_user => 'bob' and admin_password => 'carl'" do
        let(:params) { {
          'vhost'          => 'alice',
          'admin_user'     => 'bob',
          'admin_password' => 'carl',
          'with_tools'     => false
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::rabbitmq').with(
          'admin_user'     => 'bob',
          'admin_password' => 'carl',
          'with_tools'     => false
          )
        }

        include_examples 'UiTdatabank rabbitmq configuration', 'alice', 'bob', 'carl'
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'vhost'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_user'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
      end
    end
  end
end
