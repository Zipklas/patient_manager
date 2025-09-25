require "test_helper"

class BmrCalculationsControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    get bmr_calculations_calculate_url
    assert_response :success
  end

  test "should get history" do
    get bmr_calculations_history_url
    assert_response :success
  end
end
