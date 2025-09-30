# Implementing Task Views

This guide explains how to implement and customize the task views in the Strata engine, with a focus on the `index.html.erb` template.

## Quick Start Implementation

To implement the tasks index view in your application, create an `index.html.erb` file in your views directory with the following content:

```erb
<%= render template: 'strata/tasks/index', locals: {
  tasks: @tasks,
  task_types: @task_types,
  unassigned_tasks: @unassigned_tasks
} %>
```

### Required Local Variables

The view requires the following local variables to be passed:

- `tasks`: An array of `Strata::Task` objects to display in the list
- `task_types`: An array of available task types for filtering
- `unassigned_tasks`: An array of `Strata::Task` objects used to determine the state of the "Pick Next Task" button

### Controller Setup

In your controller, ensure you have the following instance variables set:

```ruby
def index
  @tasks = Strata::Task.where(assignee_id: current_user.id) # or your task retrieval logic
  @task_types = ["MyCustomTask", "OtherTask", Strata::Task.name]
  @unassigned_tasks = Strata::Task.where(assignee_id: nil) # or your unassigned tasks logic
end
```

## Internationalization (i18n)

The view uses several translation keys that you can override in your application:

```yaml
strata:
  tasks:
    index:
      title: "Tasks"
      tabs:
        assigned: "Assigned"
        completed: "Completed"
      columns:
        col_due_date: "Due Date"
        col_type: "Type"
        col_case_id: "Case ID"
        col_created_date: "Created Date"
    actions:
      pick_next: "Pick Next Task"
    messages:
      no_tasks_available: "No tasks available"
```

## URL Parameters

The view supports the following URL parameters for filtering:

- `filter_date`: Filter tasks by due date
- `filter_type`: Filter tasks by type
- `filter_status`: Filter tasks by completion status ("completed" or null)

## Related Components

- `_nav_tab.html.erb`: Shared partial for navigation tabs
- `_type_filter.html.erb`: Task type filtering component
- `_due_date_filter.html.erb`: Date filtering component
- `_no_tasks_alert.html.erb`: Empty state component
