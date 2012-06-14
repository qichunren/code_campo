require 'test_helper'

class GUserTest < ActiveSupport::TestCase
  test "follow! method" do
    a_user = create(:user)
    user1 = create(:user)
    user2 = create(:user)
    a_user.follow!(user1)
    a_user.follow!(user2)
    assert_equal 2, a_user.following.size
    assert_equal true, a_user.following.include?(user1)
    assert_equal true, a_user.following.include?(user2)
  end

  test "unflow! method" do
    a_user = create(:user)
    user1 = create(:user)
    user2 = create(:user)
    a_user.follow!(user1)
    a_user.follow!(user2)
    a_user.unfollow!(user2)
    assert_equal 1, a_user.following.size
  end

end