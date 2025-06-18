require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:test_case) { TestCase.create! }
  let!(:user) { User.create!(first_name: "Test", last_name: "User") }

  before do
    # Mock current_user for the dummy app since it doesn't have Devise
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(TasksController).to receive(:current_user_id).and_return(user.id)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "Task scopes" do
    it "unassigned scope with unassigned tasks" do
      Flex::Task.create!(case_id: test_case.id, description: "Test task")

      result = Flex::Task.unassigned
      expect(result.count).to eq(1)
    end

    it "unassigned scope with assigned tasks" do
      task = Flex::Task.create!(case_id: test_case.id, description: "Test task")
      task.assign(user.id)

      result = Flex::Task.unassigned
      expect(result.count).to eq(0)
    end

    it "next_unassigned returns earliest due task" do
      later_task = Flex::Task.create!(case_id: test_case.id, description: "Later task", due_on: Date.current + 1.day)
      earliest_task = Flex::Task.create!(case_id: test_case.id, description: "Earlier task", due_on: Date.current)

      result = Flex::Task.next_unassigned
      expect(result).to eq(earliest_task)
    end

    it "next_unassigned returns nil when no unassigned tasks" do
      task = Flex::Task.create!(case_id: test_case.id, description: "Assigned task")
      task.assign(user.id)

      result = Flex::Task.next_unassigned
      expect(result).to be_nil
    end
  end

  describe "POST /tasks/pick_up_next_task" do
    context "when unassigned tasks exist" do
      let!(:task) { Flex::Task.create!(case_id: test_case.id, description: "Test task", due_on: Date.current) }

      it "redirects to assign task path" do
        post "/tasks/pick_up_next_task"

        expect(response).to redirect_to(assign_task_path(task, user.id))
      end
    end

    context "when no unassigned tasks exist" do
      it "shows no tasks available message and stays on index" do
        post "/tasks/pick_up_next_task"

        expect(response).to redirect_to(tasks_path)
        follow_redirect!
        expect(response.body).to include("No tasks available!")
      end
    end

    context "when multiple unassigned tasks exist" do
      before do
        Flex::Task.create!(case_id: test_case.id, description: "Latest due task", due_on: Date.current + 2.days)
        Flex::Task.create!(case_id: test_case.id, description: "Middle due task", due_on: Date.current + 1.day)
        Flex::Task.create!(case_id: test_case.id, description: "Earliest due task", due_on: Date.current)
      end

      it "picks up the task with the earliest due date" do
        post "/tasks/pick_up_next_task"

        # Find which task should be picked (earliest due date)
        earliest_task = Flex::Task.incomplete.where(assignee_id: nil).order(due_on: :asc).first
        expect(response).to redirect_to(assign_task_path(earliest_task, user.id))
      end
    end
  end

  describe "PATCH /tasks/:id/assign/:user_id" do
    let!(:task) { Flex::Task.create!(case_id: test_case.id, description: "Test task") }

    it "assigns the task to the specified user" do
      patch "/tasks/#{task.id}/assign/#{user.id}"

      expect(response).to redirect_to(task_path(task))
      follow_redirect!
      expect(response.body).to include("Task assigned to you")

      task.reload
      expect(task.assignee_id).to eq(user.id)
    end

    it "shows flash message after assignment" do
      patch "/tasks/#{task.id}/assign/#{user.id}"

      follow_redirect!
      expect(flash["task-message"]).to eq("Task assigned to you")
    end
  end
end
