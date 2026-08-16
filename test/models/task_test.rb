require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "should be valid with title" do
    task = Task.new(title: "Test Task", completed: false)
    assert task.valid?
  end

  test "should not be valid without title" do
    task = Task.new(completed: false)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should not be valid with empty title" do
    task = Task.new(title: "", completed: false)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should default completed to false" do
    task = Task.create(title: "New Task")
    assert_not task.completed
  end

  test "should allow completed to be true" do
    task = Task.new(title: "Completed Task", completed: true)
    assert task.valid?
    assert task.completed
  end

  test "should save task with valid attributes" do
    task = Task.new(title: "Valid Task", completed: false)
    assert task.save
  end

  test "should not save task without title" do
    task = Task.new(completed: false)
    assert_not task.save
  end

  test "fixtures are valid" do
    assert tasks(:pending_task).valid?
    assert tasks(:completed_task).valid?
    assert tasks(:another_pending_task).valid?
  end

  test "can toggle completed status" do
    task = tasks(:pending_task)
    assert_not task.completed

    task.update(completed: true)
    assert task.completed

    task.update(completed: false)
    assert_not task.completed
  end
end
