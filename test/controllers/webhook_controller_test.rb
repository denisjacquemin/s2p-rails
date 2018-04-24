require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "should get pq_confirm" do
    get webhook_pq_confirm_url
    assert_response :success
  end

end
