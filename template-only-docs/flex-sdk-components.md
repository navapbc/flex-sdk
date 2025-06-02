# Flex SDK Components

1. Flex Data Modeler
2. Multi-Page Form Builder
3. Business Process Modeler
4. Rules Engine
5. Master Person Record

## Flex Data Modeler

Flex Attributes are used to define the data model for your application.

- Define fields that are common across many government systems with only a few lines of code.
- Minimize custom code by leveraging built-in validation logic
- Ensure data interoperability by leveraging Flex data standards.

For example, to collect name and address from your applicants would previously have required something like this:

```ruby
attribute :first_name, :string, required: true
attribute :middle_name, :string
attribute :last_name, :string, required: true
attribute :residential_street_address_line_1, :string, required: true
attribute :residential_street_address_line_2, :string
attribute :residential_city, :string, required: true
attribute :residential_state, :string, required: true
attribute :residential_zip_code, :string, required: true
attribute :mailing_street_address_line_1, :string
attribute :mailing_street_address_line_2, :string
attribute :mailing_city, :string
attribute :mailing_state, :string
attribute :mailing_zip_code, :string
```

With Flex Attributes, you can define the same fields with just a few lines of code:

```ruby
flex_attribute :name
flex_attribute :residential_address, :address
flex_attribute :mailing_address, :address
```

## Multi-Page Form Builder

Flex provides a powerful form builder that allows you to create multi-page forms with ease that leverage the [task list design pattern](https://navasage.atlassian.net/wiki/spaces/PL/pages/445382671/Task+list). This component is designed to help you build complex forms that can span multiple pages while maintaining a user-friendly interface.
