require "test_helper"

module Flex
  class Staff::DashboardControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get staff_dashboard_index_url
      assert_response :success
    end
  end
end
