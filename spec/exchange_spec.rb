require 'spec_helper'

describe 'Excange' do
  describe 'POST /api/banks' do
    it "initializes bank with supplied hash from parameter 'content'" do
      post '/api/banks', content: { 10 => 5, 2 => 3 }
      expect(last_response.status).to eq 201
      expect(last_response.body).to eq('{"msg":{"10 cents":"5 coins","2 cents":"3 coins"}}')
    end

    it "returns error message on attempt to initialize bank without content" do
      post '/api/banks'
      expect(last_response.status).to eq 400
      expect(last_response.body).to eq('{"msg":"Parameter is required"}')
    end
  end

  describe 'GET /api/exchange' do
    it "returns error message that bank is not initialized" do
      get '/api/exchange', need_change: 5
      expect(last_response.body).to eq('{"msg":"Sorry, bank not initialized yet"}')
    end

    it "exchanges amount by coins" do
      post '/api/banks', content: { 50 => 2, 25 => 8, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"50 cents":"2 coins","25 cents":"4 coins"}}')
    end

    it "exchanges amount by coins, second time" do
      post '/api/banks', content: { 50 => 0, 25 => 4, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"25 cents":"4 coins","10 cents":"10 coins"}}')
    end

    it "returns message that there is not enough money" do
      post '/api/banks', content: { 50 => 0, 25 => 0, 10 => 0, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":"Sorry, not enough money for exchange"}')
    end

    it "depends on available coins" do
      post '/api/banks', content: { 50 => 3, 25 => 6, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"50 cents":"3 coins","25 cents":"2 coins"}}')
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"25 cents":"4 coins","10 cents":"10 coins"}}')
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":"Sorry, not enough money for exchange"}')
    end

    it "returns message that there is no coins to correctly exchange" do
      post '/api/banks', content: { 30 => 7 }
      expect(last_response.body).to eq('{"msg":"Content includes invalid coins. Plese, use nominal coins: 1, 2, 5, 10, 25, 50, 100"}')
    end

  end
end
