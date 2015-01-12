require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ["lib", "spec"]
  t.name = "spec"
  # t.warning = true
  # t.verbose = true
  t.test_files = FileList['test/test.rb']
end

task :default => :spec

