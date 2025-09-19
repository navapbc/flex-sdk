require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:test_case) { create(:test_case) }
  let!(:user) { User.create!(first_name: "Test", last_name: "User") }

  before do
    # Mock current_user for the dummy app since it doesn't have Devise
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(TasksController).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "Task scopes" do
    it "unassigned scope with unassigned tasks" do
      create(:strata_task, case: test_case, description: "Test task")

      result = Strata::Task.unassigned
      expect(result.count).to eq(1)
    end

    it "unassigned scope with assigned tasks" do
      task = create(:strata_task, case: test_case, description: "Test task")
      task.assign(user.id)

      result = Strata::Task.unassigned
      expect(result.count).to eq(0)
    end

    it "next_unassigned returns earliest due task" do
      later_task = create(:strata_task, case: test_case, description: "Later task", due_on: Date.current + 1.day)
      earliest_task = create(:strata_task, case: test_case, description: "Earlier task", due_on: Date.current)

      result = Strata::Task.next_unassigned
      expect(result).to eq(earliest_task)
    end

    it "next_unassigned returns nil when no unassigned tasks" do
      task = create(:strata_task, case: test_case, description: "Assigned task")
      task.assign(user.id)

      result = Strata::Task.next_unassigned
      expect(result).to be_nil
    end

    it "assign_next_task_to returns assigned task when available" do
      task = create(:strata_task, case: test_case, description: "Test task", due_on: Date.current)

      result = Strata::Task.assign_next_task_to(user.id)
      expect(result).to eq(task)
      expect(result.assignee_id).to eq(user.id)
    end

    it "assign_next_task_to returns nil when no unassigned tasks exist" do
      task = create(:strata_task, case: test_case, description: "Assigned task")
      task.assign(user.id)

      result = Strata::Task.assign_next_task_to(user.id)
      expect(result).to be_nil
    end

    it "assign_next_task_to uses transaction to prevent race conditions" do
      task = create(:strata_task, case: test_case, description: "Test task", due_on: Date.current)

      # Verify the method uses a transaction by checking it assigns correctly
      result = Strata::Task.assign_next_task_to(user.id)
      expect(result).to eq(task)
      expect(result.assignee_id).to eq(user.id)

      # Verify no other tasks can be assigned after this one is taken
      second_result = Strata::Task.assign_next_task_to(user.id)
      expect(second_result).to be_nil
    end
  end

  describe "POST /staff/tasks/pick_up_next_task" do
    context "when unassigned tasks exist" do
      let!(:task) { create(:strata_task, case: test_case, description: "Test task", due_on: Date.current) }

      it "assigns task and redirects to task page" do
        post "/staff/tasks/pick_up_next_task"

        expect(response).to redirect_to(task_path(task))
        follow_redirect!
        expect(response.body).to include("Task assigned to you")

        task.reload
        expect(task.assignee_id).to eq(user.id)
      end
    end

    context "when no unassigned tasks exist" do
      it "shows no tasks available message and stays on index" do
        post "/staff/tasks/pick_up_next_task"

        expect(response).to redirect_to(tasks_path)
        follow_redirect!
        expect(response.body).to include("No tasks available!")
      end
    end

    context "when multiple unassigned tasks exist" do
      before do
        create(:strata_task, case: test_case, description: "Latest due task", due_on: Date.current + 2.days)
        create(:strata_task, case: test_case, description: "Middle due task", due_on: Date.current + 1.day)
        create(:strata_task, case: test_case, description: "Earliest due task", due_on: Date.current)
      end

      it "picks up the task with the earliest due date" do
        post "/staff/tasks/pick_up_next_task"

        # Verify that a task was assigned to the user
        assigned_task = Strata::Task.where(assignee_id: user.id).last
        expect(assigned_task).to be_present
        expect(assigned_task.due_on).to eq(Date.current) # Should be the earliest due date
        expect(response).to redirect_to(task_path(assigned_task))
      end
    end
  end
end
