# Getting Started with Strata SDK

Welcome to the Strata SDK! This toolkit helps you build government digital services by providing a robust framework for creating application forms, managing cases, and implementing business processes.

## What the SDK Provides
The SDK is a Rails "engine" (a gem that snaps into a Rails app). It gives you:

- Base classes: ApplicationForm, Case, etc - you subclass these instead of building from scratch
- Data attributes: Pre-built types like Address, TaxId to handle complex fields with validation and formatting built in
- Multi-page form system: The SDK provides a domain specific language (DSL) for defining flows. These are custom methods defined in the SDK that let us describe form structure. Under the hood they generate routes, controller actions, validation contexts and more.
- Additional offerrings: Business process engine, Task management, Rules engine, UI components, generators, Authorization, i18n.

## Your First Steps

When building a government digital service, the first thing you'll typically do is create an application form to implement the intake process. The Strata SDK provides all the tools you need to:

- Create user-friendly application forms
- Implement data validation and business rules
- Manage the application lifecycle from submission to processing

Ready to begin? Proceed to [Create an application form](./intake-application-forms.md) to start building your first form. Before beginning, you should have a basic ruby application spun up where you'll create your form. If you want to see some examples, check out the [dummy directory](../spec/dummy/) within this repository.

## Next Steps

After creating your application form, you can:

1. [Learn about the Strata attributes you can add to your form](./strata-attributes.md)
2. [Explore the Form Builder for rendering the form](./strata-form-builder.md)
3. [Explore Multi-page Form Flows for generating complex forms spanning multiple pages](./multi-page-form-flows.md)
4. [Create a case management business process](./case-management-business-process.md)
