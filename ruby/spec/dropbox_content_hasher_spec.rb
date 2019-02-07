# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DropboxContentHasher do
  it 'has a version number' do
    expect(DropboxContentHasher::VERSION).not_to be nil
  end

  it 'should correctly calculate content_hash of file' do
    file = Pathname.new('spec/ruby.png')
    content_hash = '78a5497e5094c82060997bd21c3a1233fb3e783c08c0b2ec9a3b32fcb5635e66'

    expect(file.exist?).to eq true
    expect(described_class.calculate(file)).to eq(content_hash)
  end
end
