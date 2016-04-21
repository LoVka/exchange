class Api::BanksController < ApplicationController
  rescue_from Bank::ExchangeError, RailsParam::Param::InvalidParameterError do |ex|
    render json: { msg: ex.message }, status: 400
  end

  rescue_from Mongoid::Errors::Validations do |ex|
    render json: { msg: ex.record.errors.full_messages.join("\n") }, status: 422
  end

  def create
    param! :content, Hash, required: true, blank: false
    Bank.delete_all
    bank = Bank.create!(content: params[:content])
    render json: { msg: Bank.pretty(bank.content) }, status: 201
  end

  def exchange
    param! :need_change, Integer, required: true
    render json: Bank.exchange(params[:need_change]), status: 200
  end

end
