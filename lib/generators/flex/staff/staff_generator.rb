require "rails/generators"

module Flex
  module Generators
    # Generator for creating staff dashboard components for applications using the flex-sdk
    class StaffGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates staff dashboard components for applications using the flex-sdk"

      def create_staff_controller
        template "staff_controller.rb", "app/controllers/staff_controller.rb"
      end

      def create_tasks_controller
        template "tasks_controller.rb", "app/controllers/tasks_controller.rb"
      end

      def create_views
        template "staff_index.html.erb", "app/views/staff/index.html.erb"
        template "tasks_index.html.erb", "app/views/tasks/index.html.erb"
        template "task_show.html.erb", "app/views/tasks/show.html.erb"
      end

      def create_spec
        template "tasks_spec.rb", "spec/requests/tasks_spec.rb"
      end

      def update_routes
        route <<~ROUTES
          scope path: "/staff" do
            # Add staff specific resources here, like cases and tasks

            resources :tasks, only: [ :index, :show, :update ] do
              collection do
                post :pick_up_next_task
              end
            end
          end

          get "staff", to: "staff#index"
        ROUTES
      end
    end
  end
end
