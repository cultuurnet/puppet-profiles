describe 'slugify' do
  it { is_expected.not_to be_nil }

  context 'without parameters' do
    it { is_expected.to run.with_params().and_raise_error(ArgumentError, %r{expects 1 argument, got none}i) }
  end

  context 'with 2 parameters' do
    it { is_expected.to run.with_params('foo', 'bar').and_raise_error(ArgumentError, %r{expects 1 argument, got 2}i) }
  end

  context 'with a string returns a string' do
    it { is_expected.to run.with_params('input_string').and_return(an_instance_of(String)) }
  end

  context 'with a lowercase pure ASCII string' do
    it { is_expected.to run.with_params('foo').and_return('foo') }
  end

  context 'with a mixed case pure ASCII string' do
    it { is_expected.to run.with_params('Bla').and_return('bla') }
  end

  context 'with a pure ASCII string and spaces' do
    it { is_expected.to run.with_params('hello world').and_return('hello-world') }
  end

  context 'with accented characters' do
    it { is_expected.to run.with_params('café').and_return('cafe') }
  end

  context 'with punctuation mark characters' do
    it { is_expected.to run.with_params('Hello, World!').and_return('hello-world') }
  end

  context 'with a combination of characters to convert' do
    it { is_expected.to run.with_params('Per-öwe, _kom_ terug!').and_return('per-owe-_kom_-terug') }
  end

  context 'with multiple space characters, possibly intermixed with punctuation marks' do
    it { is_expected.to run.with_params('before  after').and_return('before-after') }
    it { is_expected.to run.with_params('before *! after').and_return('before-after') }
  end
end
