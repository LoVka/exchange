ENV['RAILS_ENV'] = 'test'
require File.expand_path("../../config/environment", __FILE__)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    Rails.application
  end

  config.before(:each) do
    Bank.delete_all
  end
end
