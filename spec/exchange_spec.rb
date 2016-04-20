require 'spec_helper'

describe 'Excange' do
  describe 'POST /api/banks' do
    it "initializes bank with supplied hash from parameter 'content'" do
      post '/api/banks', content: { 10 => 5, 2 => 3 }
      expect(last_response.status).to eq 201
      expect(last_response.body).to eq('{"msg":{"5 coins":"10 cents","3 coins":"2 cents"}}')
    end

    it "returns error message on attempt to initialize bank without content" do
      post '/api/banks'
      expect(last_response.status).to eq 400
      expect(last_response.body).to eq('{"msg":"Parameter is required"}')
    end
  end

  describe 'GET /api/exchange' do
    it "exchanges amount by coins" do
      post '/api/banks', content: { 50 => 2, 25 => 8, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"2 coins":"50 cents","4 coins":"25 cents"}}')
    end

    it "exchanges amount by coins, second time" do
      post '/api/banks', content: { 50 => 0, 25 => 4, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"4 coins":"25 cents","10 coins":"10 cents"}}')
    end

    it "returns message that there is not enough money" do
      post '/api/banks', content: { 50 => 0, 25 => 0, 10 => 0, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":"Sorry, not enough money for exchange"}')
    end

    it "returns message that there is no coins to correctly exchange" do
      post '/api/banks', content: { 30 => 7 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":"Sorry, there are no coins to correctly exchange"}')
    end

    it "depends on available coins" do
      post '/api/banks', content: { 50 => 3, 25 => 6, 10 => 12, 2 => 5 }
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"3 coins":"50 cents","2 coins":"25 cents"}}')
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":{"4 coins":"25 cents","10 coins":"10 cents"}}')
      get '/api/exchange', need_change: 2
      expect(last_response.body).to eq('{"msg":"Sorry, not enough money for exchange"}')
    end

  end
end