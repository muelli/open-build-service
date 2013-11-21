require 'test_helper'

class ProjectLogEntryTest < ActiveSupport::TestCase
  fixtures :all

  test "create from a commit" do
    event = Event::Package.find(1067339457)
    entry = ProjectLogEntry.create_from event
    assert_equal "commit", entry.event_type
    assert_equal "New revision of a package was commited", entry.message
    assert_equal projects(:BaseDistro), entry.project
    assert_nil entry.user_name
    assert_equal packages(:pack1), entry.package
    assert_equal Date.parse("2013-08-31"), entry.datetime.to_date
    assert_equal({"files" => "Added:\n  my_file\n\n", "rev" => "1"}, entry.additional_info)
  end

  test "create from commit for a deleted package" do
    event = Event::Package.find(1067339103) #:commit_for_deleted_package
    entry = ProjectLogEntry.create_from event
    refute entry.new_record?
    assert_equal projects(:"BaseDistro2.0"), entry.project
    assert_equal users(:Iggy), entry.user
    assert_equal BsRequest.find(1000), entry.bs_request
    assert_nil entry.package
    assert_equal "isgone", entry.package_name
  end

  test "create from build_success for a deleted project" do
    event = Event::Package.find(1067339104) #:build_success_from_deleted_project
    entry = ProjectLogEntry.create_from event
    assert entry.new_record?
    assert_nil entry.id
    assert_nil entry.project
  end

  test "create from build_fail with deleted user and request" do
    event = Event::Package.find(1067339105) #:build_fails_with_deleted_user_and_request
    entry = ProjectLogEntry.create_from event
    assert_equal "build_fail", entry.event_type
    assert_equal "Package has failed to build", entry.message
    assert_equal projects(:BaseDistro), entry.project
    assert_nil entry.user
    assert_equal "no_longer_there", entry.user_name
    assert_nil entry.bs_request
    assert_equal({"rev" => "5"}, entry.additional_info)
  end

  test "#clean_older_than" do
    count = ProjectLogEntry.count
    ProjectLogEntry.clean_older_than Date.parse("2013-08-09")
    assert_equal count-1, ProjectLogEntry.count
  end
end