require 'spec_helper'

describe 'profiles::certificate' do
  context "with title => leonardo.example.com" do
    let(:title) { 'leonardo.example.com' }

    context "with certificate_source => /tmp/cert/cert1 and key_source => /tmp/cert/key1" do
      let(:params) { {
        'certificate_source' => '/tmp/cert/cert1',
        'key_source'         => '/tmp/cert/key1'
      } }

      on_supported_os.each do |os, facts|
          context "on #{os}" do
          let(:facts) { facts }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file('leonardo.example.com.bundle.crt').with(
            'path'   => '/etc/ssl/certs/leonardo.example.com.bundle.crt',
            'mode'   => '0644',
            'source' => '/tmp/cert/cert1'
          ) }

          it { is_expected.to contain_file('leonardo.example.com.key').with(
            'path'   => '/etc/ssl/private/leonardo.example.com.key',
            'mode'   => '0644',
            'source' => '/tmp/cert/key1'
          ) }
        end
      end
    end
  end

  context "with title => michelangelo.example.com" do
    let(:title) { 'michelangelo.example.com' }

    context "with certificate_source => /tmp/cert/cert2 and key_source => /tmp/cert/key2" do
      let(:params) { {
        'certificate_source' => '/tmp/cert/cert2',
        'key_source'         => '/tmp/cert/key2'
      } }

      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) { facts }

          it { is_expected.to contain_file('michelangelo.example.com.bundle.crt').with(
            'path'   => '/etc/ssl/certs/michelangelo.example.com.bundle.crt',
            'source' => '/tmp/cert/cert2'
          ) }

          it { is_expected.to contain_file('michelangelo.example.com.key').with(
            'path'   => '/etc/ssl/private/michelangelo.example.com.key',
            'source' => '/tmp/cert/key2'
          ) }
        end
      end
    end

    context "without parameters" do
      let(:params) { {} }

      it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'certificate_source'/) }
      it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'key_source'/) }
    end
  end
end
