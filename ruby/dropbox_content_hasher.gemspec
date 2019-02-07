# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dropbox_content_hasher/version'

Gem::Specification.new do |spec|
  spec.name          = 'dropbox_content_hasher'
  spec.version       = DropboxContentHasher::VERSION
  spec.authors       = ['Igor Malinovskiy']
  spec.email         = ['psy.ipm@gmail.com']

  spec.summary       = 'This gem computes hash value of file'
  spec.description   = %q{
    In order to allow Dropbox API apps to verify uploaded contents or compare remote files
    to local files without downloading them, the FileMetadata object contains a hash of the
    file contents in the content_hash property.
  }
  spec.homepage      = 'https://github.com/psyipm/dropbox_content_hasher'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
