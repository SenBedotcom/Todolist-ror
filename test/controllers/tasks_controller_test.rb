require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:pending_task)
  end

  # INDEX Tests
  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "index should display all tasks" do
    get tasks_url
    assert_select ".tasks-list"
  end

  # CREATE Tests
  test "should create task with valid attributes" do
    assert_difference("Task.count", 1) do
      post tasks_url, params: { task: { title: "New Test Task", completed: false } }
    end
  end

  test "should create task and redirect to index for html" do
    post tasks_url, params: { task: { title: "New Test Task", completed: false } }
    assert_redirected_to tasks_path
  end

  test "should not create task without title" do
    assert_no_difference("Task.count") do
      post tasks_url, params: { task: { title: "", completed: false } }
    end
    assert_response :unprocessable_entity
  end

  test "should render turbo_stream on successful create" do
    post tasks_url, params: { task: { title: "New Test Task" } }, as: :turbo_stream
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should create task with completed false by default" do
    post tasks_url, params: { task: { title: "Test Task" } }
    assert_not Task.last.completed
  end

  # UPDATE Tests
  test "should update task" do
    patch task_url(@task), params: { task: { title: "Updated Title" } }
    assert_redirected_to tasks_path
    @task.reload
    assert_equal "Updated Title", @task.title
  end

  test "should update task completion status" do
    patch task_url(@task), params: { task: { completed: true } }
    @task.reload
    assert @task.completed
  end

  test "should not update task with invalid title" do
    original_title = @task.title
    patch task_url(@task), params: { task: { title: "" } }
    @task.reload
    assert_equal original_title, @task.title
    assert_response :unprocessable_entity
  end

  test "should render turbo_stream on successful update" do
    patch task_url(@task), params: { task: { title: "Updated" } }, as: :turbo_stream
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  # DESTROY Tests
  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end
  end

  test "should redirect to index after destroy" do
    delete task_url(@task)
    assert_redirected_to tasks_path
  end

  test "should render turbo_stream on destroy" do
    delete task_url(@task), as: :turbo_stream
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  # TOGGLE Tests
  test "should toggle task from incomplete to complete" do
    task = tasks(:pending_task)
    assert_not task.completed

    patch toggle_task_url(task)
    task.reload
    assert task.completed
  end

  test "should toggle task from complete to incomplete" do
    task = tasks(:completed_task)
    assert task.completed

    patch toggle_task_url(task)
    task.reload
    assert_not task.completed
  end

  test "should toggle and redirect for html" do
    patch toggle_task_url(@task)
    assert_redirected_to tasks_path
  end

  test "should render turbo_stream on toggle" do
    patch toggle_task_url(@task), as: :turbo_stream
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should toggle multiple times" do
    task = tasks(:pending_task)
    original_state = task.completed

    # Toggle once
    patch toggle_task_url(task)
    task.reload
    assert_equal !original_state, task.completed

    # Toggle again
    patch toggle_task_url(task)
    task.reload
    assert_equal original_state, task.completed
  end

  # Integration Tests
  test "full workflow: create, toggle, update, destroy" do
    # Create
    assert_difference("Task.count", 1) do
      post tasks_url, params: { task: { title: "Workflow Test Task" } }
    end
    task = Task.last
    assert_not task.completed

    # Toggle to complete
    patch toggle_task_url(task)
    task.reload
    assert task.completed

    # Update title
    patch task_url(task), params: { task: { title: "Updated Workflow Task" } }
    task.reload
    assert_equal "Updated Workflow Task", task.title

    # Destroy
    assert_difference("Task.count", -1) do
      delete task_url(task)
    end
  end

  test "statistics should update after creating task" do
    get tasks_url
    initial_count = Task.count

    post tasks_url, params: { task: { title: "Stats Test" } }
    
    assert_equal initial_count + 1, Task.count
  end

  test "completed and pending counts should be accurate" do
    completed_count = Task.where(completed: true).count
    pending_count = Task.where(completed: false).count
    total_count = Task.count

    assert_equal total_count, completed_count + pending_count
  end
end
