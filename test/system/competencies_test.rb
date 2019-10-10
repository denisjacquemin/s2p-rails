require "application_system_test_case"

class CompetenciesTest < ApplicationSystemTestCase
  setup do
    @competency = competencies(:one)
  end

  test "visiting the index" do
    visit competencies_url
    assert_selector "h1", text: "Competencies"
  end

  test "creating a Competency" do
    visit competencies_url
    click_on "New Competency"

    fill_in "Name", with: @competency.name
    fill_in "School", with: @competency.school_id
    click_on "Create Competency"

    assert_text "Competency was successfully created"
    click_on "Back"
  end

  test "updating a Competency" do
    visit competencies_url
    click_on "Edit", match: :first

    fill_in "Name", with: @competency.name
    fill_in "School", with: @competency.school_id
    click_on "Update Competency"

    assert_text "Competency was successfully updated"
    click_on "Back"
  end

  test "destroying a Competency" do
    visit competencies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Competency was successfully destroyed"
  end
end
