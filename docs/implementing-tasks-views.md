# Implementing Task Views

This guide explains how to implement and customize the task views in the Strata engine, with a focus on the tasks index.

## Quick Start Implementation

`Strata::TasksController#index` renders the engine template `strata/tasks/index` and passes locals from `tasks_index_locals`. Host applications normally **do not** add `app/views/tasks/index.html.erb`; override `tasks_index_locals` (or `index`) in your `TasksController` subclass to customize behavior.

### Default locals

The engine supplies:

- `tasks`, `task_types`, `unassigned_tasks` (from instance variables)
- `task_row_component_class` (defaults to `Strata::Tasks::TaskRowComponent`)
- `task_row_component_options` (defaults to `{}`)

### Custom task columns

Subclass `Strata::Tasks::TaskRowComponent` and pass your class in `tasks_index_locals`, following the same pattern as `Strata::Cases::CaseRowComponent` for the cases index.

### Controller setup

Override `tasks_index_locals` when you need extra row options or a custom row component:

```ruby
protected

def tasks_index_locals
  super.merge(
    task_row_component_class: MyApp::TaskRowComponent,
    task_row_component_options: { my_data: @my_data }
  )
end
```

The default `Strata::TasksController#index` sets `@task_types`, `@tasks`, and `@unassigned_tasks` before rendering.

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
