require 'test_helper'

class RatingYearsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rating_year = rating_years(:one)
  end

  test "should get index" do
    get rating_years_url
    assert_response :success
  end

  test "should get new" do
    get new_rating_year_url
    assert_response :success
  end

  test "should create rating_year" do
    assert_difference('RatingYear.count') do
      post rating_years_url, params: { rating_year: { active: @rating_year.active, name: @rating_year.name, order: @rating_year.order } }
    end

    assert_redirected_to rating_year_url(RatingYear.last)
  end

  test "should show rating_year" do
    get rating_year_url(@rating_year)
    assert_response :success
  end

  test "should get edit" do
    get edit_rating_year_url(@rating_year)
    assert_response :success
  end

  test "should update rating_year" do
    patch rating_year_url(@rating_year), params: { rating_year: { active: @rating_year.active, name: @rating_year.name, order: @rating_year.order } }
    assert_redirected_to rating_year_url(@rating_year)
  end

  test "should destroy rating_year" do
    assert_difference('RatingYear.count', -1) do
      delete rating_year_url(@rating_year)
    end

    assert_redirected_to rating_years_url
  end
end
