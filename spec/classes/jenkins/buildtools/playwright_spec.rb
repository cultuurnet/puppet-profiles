describe 'profiles::jenkins::buildtools::playwright' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('xvfb').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libnss3').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libxrandr2').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libgbm1').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libxkbcommon0').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libxdamage1').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libxcomposite1').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libatspi2.0-0').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libcups2').with( {'ensure' => 'present'}) }
      it { is_expected.to contain_package('libatk-bridge2.0-0').with( {'ensure' => 'present'}) }
    end
  end
end
