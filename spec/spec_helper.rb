# Main directory for tests
TEST_BASE = File.join("tmp", "tests")

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents mocking or stubbing a method that does not exist on a real object
    mocks.verify_partial_doubles = true
  end

  # New RSpec 4 default
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Limit a spec run to individual examples or groups
  config.filter_run_when_matching :focus

  # Persist some state between runs to use with `--only-failures` and `--next-failure` CLI options
  # config.example_status_persistence_file_path = "spec/examples.txt"

  # Disables all monkey patching
  config.disable_monkey_patching!

  # Enable warnings
  # config.warnings = true

  # More verbose output when running an individual spec file
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies (use --seed to fix order)
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  Kernel.srand config.seed

  # Remove files created during testing
  config.after(:suite) do
    FileUtils.rm_rf(Dir[TEST_BASE]) if File.exist?(TEST_BASE)
  end
end
