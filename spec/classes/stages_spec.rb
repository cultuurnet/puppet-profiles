describe 'profiles::stages' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_stage('pre') }
      it { is_expected.to contain_stage('post') }

      it { is_expected.to contain_stage('pre').that_comes_before('Stage[main]') }
      it { is_expected.to contain_stage('post').that_requires('Stage[main]') }
    end
  end
end
