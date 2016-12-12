require 'test_helper'


#rails test test/models/message_test
class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "author_email is nil if author is nil" do
    message = Message.new(title: 'test message', author: nil)

    assert_nil(message.author_email, "Author email should be nil")
  end

  test "author_email is nil if author.email is nil" do
    author = User.new(firstname: 'Denis', lastname: 'Jacquemin', email: nil)
    message = Message.new(title: 'test message', author: author)

    assert_nil(message.author_email, "Author email should be nil")
  end

  test "author_email is nil if author.email is empty" do
    author = User.new(firstname: 'Denis', lastname: 'Jacquemin', email: "")
    message = Message.new(title: 'test message', author: author)

    assert_nil(message.author_email, "Author email should be nil")
  end

  test "author_email returns an email if author is not nil" do
    author = User.new(firstname: 'Denis', lastname: 'Jacquemin', email: 'toto@example.com')
    message = Message.new(title: 'test message', author: author)

    assert_equal(message.author_email, 'toto@example.com')
  end

  test "admins_emails is nil if message's school list is empty" do
    message = Message.new(title: 'test message', school: nil)

    assert_nil(message.admins_emails, "Admins email should be nil")
  end

  test "admins_emails is nil if school's admins list is empty" do
    school = School.new(name: 'Test school')
    message = Message.new(title: 'test message', school: school)
    assert_nil(message.admins_emails, "Admins email should be nil")
  end

  # test "admins_emails returns an array of emails" do
  #   school = School.new(id: 1, name: 'Test school')
  #   admin1 = User.new(firstname: 'Admin1', email: 'admin1@example.com', schools: [school.id])
  #   admin2 = User.new(firstname: 'Admin2', email: 'admin2@example.com', schools: [school.id])
  #   message = Message.new(title: 'test message', school: school)
  #
  #   assert_equal(['admin1@example.com', 'admin2@example.com'], message.admins_emails )
  # end


end
