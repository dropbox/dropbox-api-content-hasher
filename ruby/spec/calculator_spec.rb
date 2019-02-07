require 'spec_helper'

RSpec.describe DropboxContentHasher::Calculator do
  it 'should raise error if file does not exist' do
    calc = described_class.new('/some/file')

    expect { calc.content_hash }.to raise_error
  end

  it 'should correctly calculate content hash' do
    file = Pathname.new('spec/ruby.png')
    calc = described_class.new(file)
    content_hash = '78a5497e5094c82060997bd21c3a1233fb3e783c08c0b2ec9a3b32fcb5635e66'

    expect(file.exist?).to eq true
    expect(calc.content_hash).to eq(content_hash)
  end
end
