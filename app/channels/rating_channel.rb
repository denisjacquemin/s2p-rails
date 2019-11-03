class RatingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "rating_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def save(data)
    rating = Rating.find_or_create_by(student_id: data['rating']['s-id'], school_id: data['rating']['sc-id'], competency_id: data['rating']['current_competency_selected_id'], period_id: data['rating']['p-id'], rating_year_id: data['rating']['s-id'])
    rating.rating = data['rating']['value']
    rating.save


    # ActionCable.server.broadcast "rating_channel", rating: data['rating']

  end
end
