require "date_parser"

class FeedbackByDayController < ApplicationController
  before_action :validate_params!, only: :index

  def index
    render json: FeedbackByDay.retrieve(date, params[:page], params[:per_page])
  end

private

  def validate_params!
    head :bad_request unless valid_params?
  end

  def valid_params?
    return false if params[:page] && !params[:page].match(/^\d+$/)
    return false if params[:per_page] && !params[:per_page].match(/^\d+$/)

    date
  end

  def date
    DateParser.parse(params[:date])
  end
end
