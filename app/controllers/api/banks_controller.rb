class Api::BanksController < ApplicationController
  rescue_from Bank::ExchangeError, RailsParam::Param::InvalidParameterError do |ex|
    render json: { msg: ex.message }, status: 400
  end

  def create
    param! :content, Hash, required: true, blank: false
    Bank.all.delete
    if Bank.create!(content: params[:content])
      render json: { msg: Bank.pretty(Bank.last.content) }, status: 201
    else
      render json: { msg: 'Some wrong' }, status: 400
    end
  end

  def exchange
    render json: Bank.exchange(params), status: 200
  end

end