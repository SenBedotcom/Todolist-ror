class TasksController < ApplicationController
  before_action :set_task, only: [ :edit, :update, :destroy, :toggle ]

  def index
    @tasks = Task.all
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task was successfully created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_task_form", partial: "form", locals: { task: @task }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task was successfully updated." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@task, :edit), partial: "form", locals: { task: @task }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_path, notice: "Task was successfully deleted." }
    end
  end

  def toggle
    @task.update(completed: !@task.completed)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_path }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :completed)
  end
end
