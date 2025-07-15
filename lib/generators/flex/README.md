# Flex Generators

This directory contains Rails generators for the Flex SDK that help scaffold common patterns and files.

## Business Process Generator

The business process generator creates business process files with standardized templates and automatically configures your Rails application to start listening for events.

### Usage

```bash
bin/rails generate flex:business_process NAME [options]
```

### Arguments

- `NAME` (required): The business process name in CamelCase (e.g., "Alien", "Passport", "MedicaidApplication")

### Options

- `--case CLASS_NAME`: Custom case class name (optional)
  - Default: `{NAME}Case` (e.g., "AlienCase")
  - Example: `--case MoonCase`

- `--application_form FORM_NAME`: Custom application form name (optional)
  - Default: `{NAME}ApplicationForm` (e.g., "AlienApplicationForm") 
  - Example: `--application_form RabbitApplicationForm`

### Examples

#### Basic usage with default names
```bash
bin/rails generate flex:business_process Alien
```
Creates:
- `app/business_processes/alien_business_process.rb`
- Uses `AlienCase` and `AlienApplicationForm` in the template
- Updates `config/application.rb` with `AlienBusinessProcess.start_listening_for_events`

#### Custom case name
```bash
bin/rails generate flex:business_process Sunny --case Moon
```
Creates:
- `app/business_processes/sunny_business_process.rb`
- Uses `Moon` (custom case) and `SunnyApplicationForm` (default) in the template

#### Custom case and application form names
```bash
bin/rails generate flex:business_process Kitty --case Doggy --application_form Rabbit
```
Creates:
- `app/business_processes/kitty_business_process.rb`
- Uses `Doggy` (custom case) and `Rabbit` (custom application form) in the template

### Generated File Structure

The generator creates a business process file following this pattern:

```ruby
{NAME}BusinessProcess = Flex::BusinessProcess.define(:{name}, {Case}Case) do |bp|
  bp.applicant_task('submit_application')

  bp.start_on_application_form_created('submit_application')

  bp.transition('submit_application', '{ApplicationForm}Submitted', 'example_1')
  bp.transition('example_1', 'a_different_event', 'end')
end
```

Where:
- `{NAME}` is the CamelCase business process name
- `{name}` is the snake_case version for the symbol
- `{Case}` is the case class name (default or custom)

### Application Configuration

The generator automatically updates `config/application.rb` to include:

```ruby
config.after_initialize do
  {NAME}BusinessProcess.start_listening_for_events
end
```

If a `config.after_initialize` block already exists, the generator appends the call to the existing block. If the call already exists, it won't be duplicated.

### Error Handling

- **File already exists**: If `app/business_processes/{name}_business_process.rb` already exists, the generator will raise an error and stop processing
- **Invalid names**: The generator validates that the business process name is provided and follows Rails naming conventions

### Integration with Flex SDK

The generated business process files integrate with the Flex SDK's business process system:

- Uses `Flex::BusinessProcess.define` DSL for workflow definition
- Follows the event-driven architecture with `start_listening_for_events`
- Integrates with the case management system through the specified case class
- Works with application form lifecycle events
