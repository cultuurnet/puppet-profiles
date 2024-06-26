describe 'profiles::apt' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('apt').with(
        'update' => { 'frequency' => 'always' },
        'stage'  => 'pre'
      ) }

      it { is_expected.to contain_cron('apt clean daily').with(
        'environment' => [ 'MAILTO=infra+cron@publiq.be'],
        'command'     => '/usr/bin/apt-get clean',
        'hour'        => '3',
        'minute'      => '0'
        )
      }

      it { is_expected.to contain_cron('apt clean daily').that_requires('Class[apt]') }
    end
  end
end
