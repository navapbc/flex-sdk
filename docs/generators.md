# Flex Generators Guide

This document provides an overview of all available generators in the Flex SDK and guidance on which ones to use when starting a new project. For each generator, you can click through to see detailed usage instructions and examples.

## Quick Start Guide

When starting a new project with Flex, you'll typically want to follow this order:

1. Generate your application form using [`flex:application_form`](../lib/generators/flex/application_form/USAGE)
2. Generate your case model using [`flex:case`](../lib/generators/flex/case/USAGE)
3. Generate your business process using [`flex:business_process`](../lib/generators/flex/business_process/USAGE)
4. Add any additional tasks using [`flex:task`](../lib/generators/flex/task/USAGE)

## Available Generators

### flex:application_form

Creates a new application form model that extends `Flex::ApplicationForm`. This is typically your starting point for collecting user input data. [See full usage guide](../lib/generators/flex/application_form/USAGE)

```bash
bin/rails generate flex:application_form NAME [attribute:type attribute:type] [options]
```

### flex:case

Generates a Flex::Case model with optional business process and application form integration. Cases are the core models that represent your business entities. [See full usage guide](../lib/generators/flex/case/USAGE)

```bash
bin/rails generate flex:case NAME [attributes] [options]
```

### flex:business_process

Creates a business process file that defines the workflow and event handling for your cases. This generator automatically configures your Rails application to listen for events. [See full usage guide](../lib/generators/flex/business_process/USAGE)

```bash
bin/rails generate flex:business_process NAME [options]
```

### flex:task

Generates a Flex::Task subclass for implementing specific workflow tasks. Tasks are individual units of work within your business process. [See full usage guide](../lib/generators/flex/task/USAGE)

```bash
bin/rails generate flex:task NAME [options]
```

### flex:model

Creates a Rails model with support for Flex attributes like `:name`, `:address`, `:money`, etc. This is useful for creating supporting models that need Flex's specialized attribute types. [See full usage guide](../lib/generators/flex/model/USAGE)

```bash
bin/rails generate flex:model NAME [attribute:type attribute:type] [options]
```

### flex:migration

Creates Rails migrations with appropriate database columns for Flex attributes. This generator automatically maps Flex attribute types to their required database columns. [See full usage guide](../lib/generators/flex/migration/USAGE)

```bash
bin/rails generate flex:migration NAME [attribute:type attribute:type] [options]
```

### flex:income_records_migration

Specialized migration generator for creating income record tables with support for different period types (year_quarter or date_range). [See full usage guide](../lib/generators/flex/income_records_migration/USAGE)

```bash
bin/rails generate flex:income_records_migration NAME period_type
```

### flex:staff

Creates a standard set of files required for implementing a staff dashboard in applications using the flex-sdk. This generator scaffolds controllers, views, and tests for staff task management. [See full usage guide](../lib/generators/flex/staff/USAGE)

```bash
bin/rails generate flex:staff
```

## Generator Dependencies

- When generating a case, the generator will check for the existence of associated business process and application form classes
- The task generator will verify the existence of the flex_tasks table
- All generators that create models will automatically create the necessary database migrations

## Commonly Used Flex Attribute Types

The following attribute types are supported across various generators:

- `name` - Creates columns for first, middle, and last name
- `address` - Creates columns for street lines, city, state, and zip code
- `money` - Creates an integer column (stores cents)
- `memorable_date` - Creates a date column
- `tax_id` - Creates a string column
- `year_quarter` - Creates year and quarter integer columns
- `date_range` - Creates start and end date columns
- `array` - Creates a jsonb column for storing arrays of objects

For more details on each generator, you can run:

```bash
bin/rails generate flex:[generator_name] --help
```
