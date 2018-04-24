class PqConfirmChannel < ApplicationCable::Channel
  def subscribed
    stream_from "PqConfirmChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
