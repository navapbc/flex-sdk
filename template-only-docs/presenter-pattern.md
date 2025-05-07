# Presenter pattern

The presenter pattern translates model data into view-specific formats. Use it when you need:

1. **Polymorphic view support**
   - Transforms different models into a consistent view interface
   - Enables views to work with multiple model types
   - Examples: index and show views that support different form types

2. **Clean view/model separation**
   - Keeps views independent of model implementations
   - Centralizes data transformation logic
   - Promotes view reusability across different contexts

## Implementation guidelines

When implementing presenters, follow these content management principles:

- Keep static content (labels, headers) in views
- Move model-specific content to presenters
- Handle all translations through presenters

The `Flex::ApplicationFormPresenter` demonstrates these principles in practice.
