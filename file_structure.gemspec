# frozen_string_literal: true

require_relative 'lib/file_structure/version'

Gem::Specification.new do |spec|
  spec.name = 'file_structure'
  spec.version = FileStructure::VERSION
  spec.authors = ['Rémi Durieu']
  spec.email = ['mail@remidurieu.dev']

  spec.summary = 'Manage file structures on the file system.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/durierem/file_structure'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/github/durierem/file_structure/'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|features)/|\.(?:git))})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'
end
