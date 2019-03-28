require 'spec_helper'

describe 'profiles::ntp' do
  include_examples 'operating system support', 'profiles::ntp'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "without parameters" do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('ntp').with(
            'restrict' => [
              '-4 default kod nomodify notrap nopeer noquery',
              '-6 default kod nomodify notrap nopeer noquery',
              '127.0.0.1',
              '::1'
            ]
          )
        }

        context "on AWS EC2" do
          let(:facts) {
            facts.merge( { 'ec2_metadata' => {} } )
          }

          it { is_expected.to contain_class('ntp').with(
              'servers'  => [ '169.254.169.123'],
              'restrict' => [
                '-4 default kod nomodify notrap nopeer noquery',
                '-6 default kod nomodify notrap nopeer noquery',
                '127.0.0.1',
                '::1'
              ]
            )
          }
        end
      end

      context "with servers => [ ntp1.example.com, ntp2.example.com]" do
        let(:params) {
          { 'servers' => [ 'ntp1.example.com', 'ntp2.example.com'] }
        }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('ntp').with(
            'servers'  => [ 'ntp1.example.com', 'ntp2.example.com'],
            'restrict' => [
              '-4 default kod nomodify notrap nopeer noquery',
              '-6 default kod nomodify notrap nopeer noquery',
              '127.0.0.1',
              '::1'
            ]
          )
        }

        context "on AWS EC2" do
          let(:facts) {
            facts.merge( { 'ec2_metadata' => {} } )
          }

          it { is_expected.to contain_class('ntp').with(
              'servers'  => [ '169.254.169.123'],
              'restrict' => [
                '-4 default kod nomodify notrap nopeer noquery',
                '-6 default kod nomodify notrap nopeer noquery',
                '127.0.0.1',
                '::1'
              ]
            )
          }
        end
      end

      context "with servers => 1.2.3.4" do
        let(:params) {
          { 'servers' => '1.2.3.4' }
        }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /parameter 'servers' expects an Array value/) }
      end
    end
  end
end
