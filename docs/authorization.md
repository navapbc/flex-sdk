# Authorization in Strata SDK

The Strata SDK provides built-in base [Pundit](https://github.com/varvet/pundit) authorization policies that implement secure default authorization rules for government digital services.

## Built-in Policy Modules

### ApplicationFormPolicy

The `Strata::ApplicationFormPolicy` module provides secure defaults for application form authorization. This module ensures that users can only access their own application forms and can modify them until the application is submitted, after which they can no longer update the application form.

#### Usage

```ruby
class MyApplicationFormPolicy < ApplicationPolicy
  include Strata::ApplicationFormPolicy
end
```
