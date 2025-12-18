describe 'profiles::firewall::rules' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with all virtual resources realized" do
        let(:pre_condition) { 'Firewall <| |>' }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_firewall('100 accept SSH traffic').with(
          'proto'  => 'tcp',
          'dport'  => '22',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('200 accept NRPE traffic').with(
          'proto'  => 'tcp',
          'dport'  => '5666',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept HTTP traffic').with(
          'proto'  => 'tcp',
          'dport'  => '80',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept HTTPS traffic').with(
          'proto'  => 'tcp',
          'dport'  => '443',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept SMTP traffic').with(
          'proto'  => 'tcp',
          'dport'  => '25',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept puppetserver HTTPS traffic').with(
          'proto'  => 'tcp',
          'dport'  => '8140',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('300 accept puppetdb HTTPS traffic').with(
          'proto'  => 'tcp',
          'dport'  => '8081',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept redis traffic').with(
          'proto'  => 'tcp',
          'dport'  => '6379',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept meilisearch traffic').with(
          'proto'  => 'tcp',
          'dport'  => '7700',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept mysql traffic').with(
          'proto'  => 'tcp',
          'dport'  => '3306',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept vault traffic').with(
          'proto'  => 'tcp',
          'dport'  => '8200',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept mongodb traffic').with(
          'proto'  => 'tcp',
          'dport'  => '27017',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept mailpit SMTP traffic').with(
          'proto'  => 'tcp',
          'dport'  => '1025',
          'action' => 'accept'
        ) }

        it { is_expected.to contain_firewall('400 accept logstash filebeat traffic').with(
          'proto'  => 'tcp',
          'dport'  => '5000',
          'action' => 'accept'
        ) }
      end
    end
  end
end
