class WebhookController < ApplicationController
  def pq_confirm
    PaymentBroadCastJob.perform_later params[:pqid]
    head :ok, content_type: "text/html"
  end
end
