require 'test_helper'

class SchoolYearsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school_year = school_years(:one)
  end

  test "should get index" do
    get school_years_url
    assert_response :success
  end

  test "should get new" do
    get new_school_year_url
    assert_response :success
  end

  test "should create school_year" do
    assert_difference('SchoolYear.count') do
      post school_years_url, params: { school_year: { end_date: @school_year.end_date, name: @school_year.name, start_date: @school_year.start_date } }
    end

    assert_redirected_to school_year_url(SchoolYear.last)
  end

  test "should show school_year" do
    get school_year_url(@school_year)
    assert_response :success
  end

  test "should get edit" do
    get edit_school_year_url(@school_year)
    assert_response :success
  end

  test "should update school_year" do
    patch school_year_url(@school_year), params: { school_year: { end_date: @school_year.end_date, name: @school_year.name, start_date: @school_year.start_date } }
    assert_redirected_to school_year_url(@school_year)
  end

  test "should destroy school_year" do
    assert_difference('SchoolYear.count', -1) do
      delete school_year_url(@school_year)
    end

    assert_redirected_to school_years_url
  end
end
