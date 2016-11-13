# spec/spec_helper.rb
require 'rack/test'
require 'rake'
require 'rspec'
require 'faker'

# RSpecMixin
module RSpecMixin
  unless RSpecMixin.const_defined?( :ActionTests )
    require File.expand_path( '../action_create_spec.rb', __FILE__ )
    require File.expand_path( '../action_read_spec.rb',   __FILE__ )
    require File.expand_path( '../action_update_spec.rb', __FILE__ )
    require File.expand_path( '../action_delete_spec.rb', __FILE__ )
    require File.expand_path( '../action_list_spec.rb',   __FILE__ )

    include Rack::Test::Methods
  end
end

# RSpec.shared_examples 'Basic tests' do
#   it 'should list routes in home page' do
#     get '/'
#     expect( last_response.status ).to eq( 200 )
#     # TODO: check the content partially
#     # expect( last_response.body ).to eq( 'Hello world!' )
#   end
# end

RSpec.configure do |config|
  config.include RSpecMixin

  config.filter_run :run_single_tests if RSpec.configuration.files_to_run.length > 1

  # config.run_all_when_everything_filtered = true

  # config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  # config.profile_examples = 10

  # config.order = :random

  # Kernel.srand config.seed

  # config.before(:each) do
  #   db = []
  # end

  # config.expect_with :rspec do |expectations|
  #   expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  # end

  # config.mock_with :rspec do |mocks|
  #   mocks.verify_partial_doubles = true
  # end
end
