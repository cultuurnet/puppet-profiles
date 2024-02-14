describe 'profiles' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('profiles::stages') }
      it { is_expected.to contain_class('profiles::apt') }
      it { is_expected.to contain_class('profiles::groups') }
      it { is_expected.to contain_class('profiles::users') }
      it { is_expected.to contain_class('profiles::files') }

      it { is_expected.to contain_class('profiles::apt::repositories').with(
        'stage' => 'pre'
      ) }
    end
  end
end
