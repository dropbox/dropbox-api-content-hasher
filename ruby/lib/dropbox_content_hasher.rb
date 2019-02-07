require 'dropbox_content_hasher/version'

module DropboxContentHasher
  autoload :Calculator, 'dropbox_content_hasher/calculator'

  class << self
    def calculate(path)
      Calculator.new(path).content_hash
    end
  end
end
