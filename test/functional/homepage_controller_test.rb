require 'test_helper'

class HomepageControllerTest < ActionController::TestCase
  def setup
    @user = create :user
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get dashboard for logged user" do
    login_as @user
    get :dashboard
    assert_response :success
  end

  test "should be redirected to login page" do
    get :dashboard
    assert_redirected_to login_url
  end
end
