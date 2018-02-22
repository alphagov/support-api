require 'date_parser'

class FeedbackByDayController < ApplicationController
  def index
    unless date
      head :bad_request
      return
    end
    render json: {results: FeedbackByDay.retrieve(date)}
  end

private
  def date
    DateParser.parse(params[:date])
  end
end
