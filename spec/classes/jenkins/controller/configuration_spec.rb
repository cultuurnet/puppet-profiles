require 'spec_helper'

describe 'profiles::jenkins::controller::configuration' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with url => https://jenkins.foobar.com/ and admin_password => passw0rd" do
        let(:params) { {
          'url'            =>  'https://jenkins.foobar.com/',
          'admin_password' => 'passw0rd'
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration').with(
          'url'              =>  'https://jenkins.foobar.com/',
          'admin_password'   => 'passw0rd',
          'credentials'      => [],
          'global_libraries' => []
        ) }


        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => {
                               'url'            => 'https://jenkins.foobar.com/',
                               'admin_password' => 'passw0rd'
                             }
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('git').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => {
                               'user_name'  => 'publiq Jenkins',
                               'user_email' => 'jenkins@publiq.be'
                             }
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('swarm').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('mailer').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('copyartifact').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('ws-cleanup').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('slack').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('workflow-aggregator').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('pipeline-utility-steps').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('ssh-steps').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('blueocean').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => nil
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('plain-credentials').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => []
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('ssh-credentials').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => []
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('workflow-cps-global-lib').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => []
        ) }

        it { is_expected.to contain_class('profiles::jenkins::controller::configuration::reload') }
        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'admin',
          'password' => 'passw0rd'
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('mailer').that_comes_before('Profiles::Jenkins::Plugin[configuration-as-code]') }
        it { is_expected.to contain_profiles__jenkins__plugin('git').that_comes_before('Profiles::Jenkins::Plugin[workflow-cps-global-lib]') }
        it { is_expected.to contain_profiles__jenkins__plugin('ssh-credentials').that_comes_before('Profiles::Jenkins::Plugin[workflow-cps-global-lib]') }
        it { is_expected.to contain_profiles__jenkins__plugin('git').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').that_requires('Class[profiles::jenkins::controller::configuration::reload]') }
      end

      context "with url => https://builds.foobar.com/, admin_password => letmein, credentials => { id => 'foo', type => 'string', secret => 'bla'} and global_libraries => { git_url => 'git@example.com:org/repo.git', git_ref => 'main', credential_id => 'mygitcred'}" do
        let(:params) { {
          'url'              =>  'https://builds.foobar.com/',
          'admin_password'   => 'letmein',
          'credentials'      => { 'id' => 'foo', 'type' => 'string', 'secret' => 'bla'},
          'global_libraries' => { 'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred'}
        } }

        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
          'configuration' => {
                               'url'            => 'https://builds.foobar.com/',
                               'admin_password' => 'letmein'
                             }
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('plain-credentials').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => [{ 'id' => 'foo', 'type' => 'string', 'secret' => 'bla'}]
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('workflow-cps-global-lib').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => [{ 'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred'}]
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'admin',
          'password' => 'letmein'
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('plain-credentials').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
        it { is_expected.to contain_profiles__jenkins__plugin('ssh-credentials').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
      end

      context "with url => https://builds.foobar.com/, admin_password => letmein, credentials => [{ id => 'token1', type => 'string', secret => 'secret1'}, { id => 'token2', type => 'string', secret => 'secret2'}, { id => 'key1', type => 'private_key', key => 'privkey1'}, { id => 'key2', type => 'private_key', key => 'privkey2'}] and global_libraries => [{'git_url' => 'git@foo.com:bar/baz.git', 'git_ref' => 'develop', 'credential_id' => 'gitkey'}, {'git_url' => 'git@example.com:org/repo.git', 'git_ref' => 'main', 'credential_id' => 'mygitcred'}]" do
        let(:params) { {
          'url'              =>  'https://builds.foobar.com/',
          'admin_password'   => 'letmein',
          'credentials'      => [
                                  { 'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                                  { 'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'},
                                  { 'id' => 'key1', 'type' => 'private_key', 'secret' => 'privkey1'},
                                  { 'id' => 'key2', 'type' => 'private_key', 'secret' => 'privkey2'}
                                ],
          'global_libraries' => [
                                  {
                                    'git_url'       => 'git@foo.com:bar/baz.git',
                                    'git_ref'       => 'develop',
                                    'credential_id' => 'gitkey'
                                  },
                                  {
                                    'git_url'       => 'git@example.com:org/repo.git',
                                    'git_ref'       => 'main',
                                    'credential_id' => 'mygitcred'
                                  }
                                ]
        } }

        it { is_expected.to contain_profiles__jenkins__plugin('configuration-as-code').with(
          'configuration' => {
                               'url'            => 'https://builds.foobar.com/',
                               'admin_password' => 'letmein'
                             }
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('plain-credentials').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => [
                               { 'id' => 'token1', 'type' => 'string', 'secret' => 'secret1'},
                               { 'id' => 'token2', 'type' => 'string', 'secret' => 'secret2'}
                             ]
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('ssh-credentials').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => [
                               { 'id' => 'key1', 'type' => 'private_key', 'secret' => 'privkey1'},
                               { 'id' => 'key2', 'type' => 'private_key', 'secret' => 'privkey2'}
                             ]
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('workflow-cps-global-lib').with(
          'ensure'        => 'present',
          'restart'       => false,
          'configuration' => [
                               {
                                 'git_url'       => 'git@foo.com:bar/baz.git',
                                 'git_ref'       => 'develop',
                                 'credential_id' => 'gitkey'
                               },
                               {
                                 'git_url'       => 'git@example.com:org/repo.git',
                                 'git_ref'       => 'main',
                                 'credential_id' => 'mygitcred'
                               }
                             ]
        ) }

        it { is_expected.to contain_class('profiles::jenkins::cli::credentials').with(
          'user'     => 'admin',
          'password' => 'letmein'
        ) }

        it { is_expected.to contain_profiles__jenkins__plugin('plain-credentials').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
        it { is_expected.to contain_profiles__jenkins__plugin('ssh-credentials').that_notifies('Class[profiles::jenkins::controller::configuration::reload]') }
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'url'/) }
        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'admin_password'/) }
      end
    end
  end
end
