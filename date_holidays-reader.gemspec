# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date_holidays/reader/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'date_holidays-reader'
  spec.version       = DateHolidays::Reader::VERSION
  spec.authors       = ['Ryan Gerry']
  spec.email         = ['rgerry@bluemarblepayroll.com']

  spec.summary       = 'A read-only Ruby wrapper for the date-holidays Node module'
  spec.description   = <<~DESCRIPTION
    This provides a read-only interace over the data provided by the
    date-holidays Node module available at https://github.com/commenthol/date-holidays .'
  DESCRIPTION
  spec.homepage = 'http://www.github.com/bluemarblepayroll/date_holidays-reader/'
  spec.metadata['source_code_uri'] = 'https://github.com/bluemarblepayroll/date_holidays-reader'
  spec.metadata['changelog_uri'] = 'https://github.com/bluemarblepayroll/date_holidays-reader/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    git_files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    node_bin  = Dir.glob('node_bin/*')

    git_files + node_bin
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'
  spec.add_dependency 'acts_as_hashable', '~> 1'
  spec.add_dependency 'caution'
  spec.add_dependency 'os', '~> 1'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '~> 1'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov', '~> 0.21.1'
  spec.add_development_dependency 'simplecov-console', '~> 0.7'
  spec.add_development_dependency 'terminal-notifier-guard'
end
# rubocop:enable Metrics/BlockLength
