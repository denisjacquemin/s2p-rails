require "application_system_test_case"

class RatingCommentsTest < ApplicationSystemTestCase
  setup do
    @rating_comment = rating_comments(:one)
  end

  test "visiting the index" do
    visit rating_comments_url
    assert_selector "h1", text: "Rating Comments"
  end

  test "creating a Rating comment" do
    visit rating_comments_url
    click_on "New Rating Comment"

    fill_in "Comment", with: @rating_comment.comment
    fill_in "Order", with: @rating_comment.order
    fill_in "School", with: @rating_comment.school_id
    fill_in "Title", with: @rating_comment.title
    click_on "Create Rating comment"

    assert_text "Rating comment was successfully created"
    click_on "Back"
  end

  test "updating a Rating comment" do
    visit rating_comments_url
    click_on "Edit", match: :first

    fill_in "Comment", with: @rating_comment.comment
    fill_in "Order", with: @rating_comment.order
    fill_in "School", with: @rating_comment.school_id
    fill_in "Title", with: @rating_comment.title
    click_on "Update Rating comment"

    assert_text "Rating comment was successfully updated"
    click_on "Back"
  end

  test "destroying a Rating comment" do
    visit rating_comments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rating comment was successfully destroyed"
  end
end
