class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.integer :school_id
      t.uuid :uuid
      t.integer :status # Konecto's Status
      t.monetize :price_cents
      t.integer :mode #payconiq / cache / bancontact

      # payconiq specific columns
      t.string :pq_transaction_id
      t.string :pq_status
        # TIMEDOUT: If the user for some reason still has not paid after 2 minutes.
        # CANCELED: when the user cancels a transaction after scanning it.
        # FAILED: something went wrong during the payment process (wrong PIN provided by a user).
        # SUCCEEDED: a transaction was confirmed by the user.
        # PENDING: the transaction is waiting for confirmation from the user.
      t.string :pq_transaction_signature # The Payconiq-generated asymmetric signature using the algorithm specified with the X-Security-Algorithm.
      t.string :pq_security_timestamp # When the request/event was generated
      t.string :pq_security_key # The X509 public key certificate from Payconiq. You can download the certificate from this URL and use it to verify the signature
      t.string :pq_security_algorithm # The algorithm that Payconiq used to generate the signature and that you can use to verify the signature
      t.timestamps
    end
  end
end
