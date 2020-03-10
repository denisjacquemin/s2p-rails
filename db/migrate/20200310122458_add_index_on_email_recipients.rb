class AddIndexOnEmailRecipients < ActiveRecord::Migration[5.2]
  def change
    add_index :email_recipients, [:message_id, :status, :email ], :name => 'index_email_recipients_for_exists_query'
  # Mar 10 12:59:07 s2p-analytics-api-prod app/worker.1: D, [2020-03-10T11:59:06.749998 #4] DEBUG -- : [ActiveJob] [HandleSendgridWebhookJob] [e459b5d6-f9a9-4a34-ac84-674f0e9bb24e]   EmailRecipient Exists (657.0ms)  SELECT  1 AS one FROM "email_recipients" WHERE "email_recipients"."students" = $1 AND "email_recipients"."message_id" = $2 AND "email_recipients"."email" = $3 AND "email_recipients"."status" = $4 LIMIT $5  [["students", "red77iyi.h@gmail.com (Ilyass Hamdi, Inaya Hamdi)"], ["message_id", 59034], ["email", "red77iyi.h@gmail.com"], ["status", "open"], ["LIMIT", 1]]
  end
end
