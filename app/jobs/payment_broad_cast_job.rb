class PaymentBroadCastJob < ApplicationJob
  queue_as :default

  def perform(pq_transaction_id)
    ActionCable.server.broadcast 'PqConfirmChannel', pq_transaction_id: pq_transaction_id
  end
end
