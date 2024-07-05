describe 'profiles::s3fs' do
  include_examples 'operating system support'

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'without parameters' do
        let(:params) { {} }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profiles::s3fs').with(
          'version'               => 'installed',
          'aws_access_key_id'     => nil,
          'aws_secret_access_key' => nil,
        ) }

        it { is_expected.to contain_package('s3fs').with(
          'ensure' => 'installed'
        ) }

        it { is_expected.to contain_file('s3fs-passwordfile').with(
          'ensure' => 'absent',
          'path'   => '/etc/passwd-s3fs'
        ) }
      end

      context 'with version => 1.2.3, aws_access_key_id => secret_key_id and aws_secret_access_key => secret_access_key' do
        let(:params) { {
          'version'               => '1.2.3',
          'aws_access_key_id'     => 'secret_key_id',
          'aws_secret_access_key' => 'secret_access_key'
        } }

        it { is_expected.to contain_package('s3fs').with(
          'ensure' => '1.2.3'
        ) }

        it { is_expected.to contain_file('s3fs-passwordfile').with(
          'ensure'  => 'file',
          'path'    => '/etc/passwd-s3fs',
          'mode'    => '0640',
          'content' => 'secret_key_id:secret_access_key'
        ) }
      end
    end
  end
end
