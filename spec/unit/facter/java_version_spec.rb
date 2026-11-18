describe 'java_version' do
  before :each do
    Facter.clear
  end

  context 'without java installed' do
    before :each do
      allow(Facter::Core::Execution).to receive(:which).with('java').and_return(nil)
    end

    it do
      expect(Facter.fact(:java_version).value).to eq(nil)
    end
  end

  context 'with java 21.0.5 installed' do
    before :each do
      allow(Facter::Core::Execution).to receive(:which).with('java').and_return('/usr/bin/java')
      allow(Facter::Util::Resolution).to receive(:exec).with('java -Xmx16m -version 2>&1').and_return(
        "openjdk version \"21.0.5\" 2024-10-15\nOpenJDK Runtime Environment (build 21.0.5+11-Ubuntu-1ubuntu120.04)\nOpenJDK 64-Bit Server VM (build 21.0.5+11-Ubuntu-1ubuntu120.04, mixed mode, sharing)"
      )
    end

    it do
      expect(Facter.fact(:java_version).value).to eq('21.0.5')
    end
  end

  context 'with java 17.0.21.0.3 installed' do
    before :each do
      allow(Facter::Core::Execution).to receive(:which).with('java').and_return('/usr/bin/java')
      allow(Facter::Util::Resolution).to receive(:exec).with('java -Xmx16m -version 2>&1').and_return(
        "openjdk version \"17.0.21.0.3\" 2026-10-24\nOpenJDK Runtime Environment (build 17.0.21.0.3+1-1-24.04.1-Ubuntu)\nOpenJDK 64-Bit Server VM (build 17.0.21.0.3+1-1-24.04.1-Ubuntu, mixed mode, sharing)"
      )
    end

    it do
      expect(Facter.fact(:java_version).value).to eq('17.0.21.0.3')
    end
  end
end
