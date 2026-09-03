# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # Rubocop isn't available in all environments
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new("pact:verify_v2") do |task|
  task.pattern = "spec/pact/consumers/**/*_spec.rb"
  task.rspec_opts = "--tag pact_v2"
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[rubocop spec pact:verify_v2]
