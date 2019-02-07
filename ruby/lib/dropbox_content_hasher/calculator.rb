module DropboxContentHasher
  class Calculator
    BLOCK_SIZE = (4 * 1024 * 1024).to_f.freeze

    class FileDoesNotExist < StandardError; end

    def initialize(path)
      @file = Pathname.new(path)
    end

    def content_hash
      raise FileDoesNotExist unless @file.exist?

      Digest::SHA256.hexdigest(hashes.join)
    end

    private

    def hashes
      Array.new(blocks_count) do |i|
        Digest::SHA256.digest(@file.binread(BLOCK_SIZE, BLOCK_SIZE * i))
      end
    end

    def blocks_count
      (@file.size / BLOCK_SIZE).ceil
    end
  end
end
