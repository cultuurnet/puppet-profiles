require 'spec_helper'

RSpec.shared_examples "UDB3 rabbitmq configuration" do |vhost, admin_user, admin_password|
  it { is_expected.to contain_rabbitmq_vhost("#{vhost}") }

  it { is_expected.to contain_rabbitmq_user_permissions("#{admin_user}@#{vhost}").with(
    'configure_permission' => '.*',
    'read_permission'      => '.*',
    'write_permission'     => '.*'
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("udb2.x.entry@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
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

  it { is_expected.to contain_rabbitmq_exchange("cdbxml.x.entry@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("udb3.q.udb2-entry@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb2.x.entry@udb3.q.udb2-entry@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("cdbxml.q.udb3-domain-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_queue("uitpas.q.udb3-domain-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@cdbxml.q.udb3-domain-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_binding("udb3.x.domain-events@uitpas.q.udb3-domain-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_queue("solr.q.udb3-cdbxml@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("cdbxml.x.entry@solr.q.udb3-cdbxml@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("uitid.x.uitpas-events@#{vhost}").with(
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

  it { is_expected.to contain_rabbitmq_binding("uitid.x.uitpas-events@udb3.q.uitpas-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("imports.x.entry@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("udb3.q.imports-entry@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("imports.x.entry@udb3.q.imports-entry@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }

  it { is_expected.to contain_rabbitmq_exchange("curators.x.events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'type'        => 'topic',
    'internal'    => false,
    'auto_delete' => false,
    'durable'     => true
    )
  }

  it { is_expected.to contain_rabbitmq_queue("udb3.q.curators-events@#{vhost}").with(
    'user'        => admin_user,
    'password'    => admin_password,
    'durable'     => true,
    'auto_delete' => false
    )
  }

  it { is_expected.to contain_rabbitmq_binding("curators.x.events@udb3.q.curators-events@#{vhost}").with(
    'user'             => admin_user,
    'password'         => admin_password,
    'destination_type' => 'queue',
    'routing_key'      => '#',
    'arguments'        => {}
    )
  }
end

describe 'profiles::udb3::rabbitmq' do
  context "with vhost => 'foo', admin_user => 'bar' and admin_password => 'baz'" do
    let(:params) { {
      'vhost'          => 'foo',
      'admin_user'     => 'bar',
      'admin_password' => 'baz',
      'with_tools'     => true
    } }

    include_examples 'operating system support', 'profiles::rabbitmq'

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::rabbitmq').with(
          'admin_user'     => 'bar',
          'admin_password' => 'baz',
          'with_tools'     => true
          )
        }

        include_examples 'UDB3 rabbitmq configuration', 'foo', 'bar', 'baz'
      end
    end
  end

  context "with vhost => 'alice', admin_user => 'bob' and admin_password => 'carl'" do
    let(:params) { {
      'vhost'          => 'alice',
      'admin_user'     => 'bob',
      'admin_password' => 'carl',
      'with_tools'     => false
    } }

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::rabbitmq').with(
          'admin_user'     => 'bob',
          'admin_password' => 'carl',
          'with_tools'     => false
          )
        }

        include_examples 'UDB3 rabbitmq configuration', 'alice', 'bob', 'carl'
      end
    end
  end

  context "without parameters" do
    let(:params) { { } }

    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'vhost'/) }
    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_user'/) }
    it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
  end
end
