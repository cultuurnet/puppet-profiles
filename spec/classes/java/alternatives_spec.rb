require 'spec_helper'

describe 'profiles::java::alternatives' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context "with default_version => 8" do
        let(:params) { {
          'default_version' => 8
        } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::java::alternatives').with(
          'default_version' => 8,
          'distribution'    => 'jre',
          'headless'        => true
        ) }

        it { is_expected.to contain_shellvar('JAVA_HOME').with(
          'ensure' => 'present',
          'target' => '/etc/environment',
          'value'  => '/usr/lib/jvm/java-8-openjdk-amd64'
        ) }

        context "with distribution => jre and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => true
            }
          ) }

          ['rmid', 'java', 'keytool', 'jjs', 'pack200', 'rmiregistry', 'unpack200', 'orbd', 'servertool', 'tnameserv'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jre and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => false
            }
          ) }

          ['rmid', 'java', 'keytool', 'jjs', 'pack200', 'rmiregistry', 'unpack200', 'orbd', 'servertool', 'tnameserv', 'policytool'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => true
            }
          ) }

          ['rmid', 'java', 'keytool', 'jjs', 'pack200', 'rmiregistry', 'unpack200', 'orbd', 'servertool', 'tnameserv'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/#{command}"
            ) }
          end

          ['idlj', 'jdeps', 'wsimport', 'rmic', 'jinfo', 'jsadebugd', 'native2ascii', 'jstat', 'javac', 'javah', 'clhsdb', 'jstack', 'jrunscript', 'javadoc', 'javap', 'jar', 'xjc', 'hsdb', 'schemagen', 'jps', 'extcheck', 'jmap', 'jstatd', 'jhat', 'jdb', 'serialver', 'jfr', 'wsgen', 'jcmd', 'jarsigner'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => false
            }
          ) }

          ['rmid', 'java', 'keytool', 'jjs', 'pack200', 'rmiregistry', 'unpack200', 'orbd', 'servertool', 'tnameserv', 'policytool'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/#{command}"
            ) }
          end

          ['idlj', 'jdeps', 'wsimport', 'rmic', 'jinfo', 'jsadebugd', 'native2ascii', 'jstat', 'javac', 'javah', 'clhsdb', 'jstack', 'jrunscript', 'javadoc', 'javap', 'jar', 'xjc', 'hsdb', 'schemagen', 'jps', 'extcheck', 'jmap', 'jstatd', 'jhat', 'jdb', 'serialver', 'jfr', 'wsgen', 'jcmd', 'jarsigner', 'appletviewer', 'jconsole'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-8-openjdk-amd64/bin/#{command}"
            ) }
          end
        end
      end

      context "with default_version => 11" do
        let(:params) { {
          'default_version' => 11
        } }

        context "with distribution => jre and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => true
            }
          ) }

          ['java', 'jjs', 'keytool', 'rmid', 'rmiregistry', 'pack200', 'unpack200'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jre and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => false
            }
          ) }

          ['java', 'jjs', 'keytool', 'rmid', 'rmiregistry', 'pack200', 'unpack200'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => true
            }
          ) }

          ['java', 'jjs', 'keytool', 'rmid', 'rmiregistry', 'pack200', 'unpack200'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'rmic', 'serialver', 'jaotc', 'jhsdb'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => false
            }
          ) }

          ['java', 'jjs', 'keytool', 'rmid', 'rmiregistry', 'pack200', 'unpack200'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'rmic', 'serialver', 'jaotc', 'jhsdb', 'jconsole'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-11-openjdk-amd64/bin/#{command}"
            ) }
          end
        end
      end

      context "with default_version => 16" do
        let(:params) { {
          'default_version' => 16
        } }

        context "with distribution => jre and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => true
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmid', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jre and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => false
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmid', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => true
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmid', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'serialver', 'jaotc', 'jhsdb'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => false
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmid', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'serialver', 'jaotc', 'jhsdb', 'jconsole'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-16-openjdk-amd64/bin/#{command}"
            ) }
          end
        end
      end

      context "with default_version => 17" do
        let(:params) { {
          'default_version' => 17
        } }

        context "with distribution => jre and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => true
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jre and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jre',
              'headless'     => false
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => true" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => true
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'serialver', 'jhsd'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end
        end

        context "with distribution => jdk and headless => false" do
          let(:params) { super().merge(
            {
              'distribution' => 'jdk',
              'headless'     => false
            }
          ) }

          ['java', 'jpackage', 'keytool', 'rmiregistry'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end

          ['jar', 'jarsigner', 'javac', 'javadoc', 'javap', 'jcmd', 'jdb', 'jdeprscan', 'jdeps', 'jfr', 'jimage', 'jinfo', 'jlink', 'jmap', 'jmod', 'jps', 'jrunscript', 'jshell', 'jstack', 'jstat', 'jstatd', 'serialver', 'jhsd', 'jconsole'].each do |command|
            it { is_expected.to contain_alternatives(command).with(
              'path' => "/usr/lib/jvm/java-17-openjdk-amd64/bin/#{command}"
            ) }
          end
        end
      end

      context "without parameters" do
        let(:params) { {} }

        it { expect { catalogue }.to raise_error(Puppet::ParseError, /expects a value for parameter 'default_version'/) }
      end
    end
  end
end
