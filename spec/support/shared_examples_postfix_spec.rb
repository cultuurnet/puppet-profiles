RSpec.shared_examples "postfix daemon directory" do |os_release|
  case os_release
  when '14.04'
    it { is_expected.to contain_class('postfix::server').with(
      'daemon_directory' => '/usr/lib/postfix'
      )
    }
  when '16.04'
    it { is_expected.to contain_class('postfix::server').with(
      'daemon_directory' => '/usr/lib/postfix/sbin'
      )
    }
  end
end
