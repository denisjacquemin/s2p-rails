require "application_system_test_case"

class RatingYearsTest < ApplicationSystemTestCase
  setup do
    @rating_year = rating_years(:one)
  end

  test "visiting the index" do
    visit rating_years_url
    assert_selector "h1", text: "Rating Years"
  end

  test "creating a Rating year" do
    visit rating_years_url
    click_on "New Rating Year"

    fill_in "Active", with: @rating_year.active
    fill_in "Name", with: @rating_year.name
    fill_in "Order", with: @rating_year.order
    click_on "Create Rating year"

    assert_text "Rating year was successfully created"
    click_on "Back"
  end

  test "updating a Rating year" do
    visit rating_years_url
    click_on "Edit", match: :first

    fill_in "Active", with: @rating_year.active
    fill_in "Name", with: @rating_year.name
    fill_in "Order", with: @rating_year.order
    click_on "Update Rating year"

    assert_text "Rating year was successfully updated"
    click_on "Back"
  end

  test "destroying a Rating year" do
    visit rating_years_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rating year was successfully destroyed"
  end
end
