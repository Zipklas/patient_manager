require "test_helper"

class BmiCalculationsControllerTest < ActionDispatch::IntegrationTest
  test "should get calculate" do
    get bmi_calculations_calculate_url
    assert_response :success
  end
end
