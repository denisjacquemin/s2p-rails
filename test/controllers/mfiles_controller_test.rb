require 'test_helper'

class MfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mfile = mfiles(:one)
  end

  test "should get index" do
    get mfiles_url
    assert_response :success
  end

  test "should get new" do
    get new_mfile_url
    assert_response :success
  end

  test "should create mfile" do
    assert_difference('Mfile.count') do
      post mfiles_url, params: { mfile: { file_url: @mfile.file_url, filename: @mfile.filename, message_id: @mfile.message_id, school_id: @mfile.school_id } }
    end

    assert_redirected_to mfile_path(Mfile.last)
  end

  test "should show mfile" do
    get mfile_url(@mfile)
    assert_response :success
  end

  test "should get edit" do
    get edit_mfile_url(@mfile)
    assert_response :success
  end

  test "should update mfile" do
    patch mfile_url(@mfile), params: { mfile: { file_url: @mfile.file_url, filename: @mfile.filename, message_id: @mfile.message_id, school_id: @mfile.school_id } }
    assert_redirected_to mfile_path(@mfile)
  end

  test "should destroy mfile" do
    assert_difference('Mfile.count', -1) do
      delete mfile_url(@mfile)
    end

    assert_redirected_to mfiles_path
  end
end
