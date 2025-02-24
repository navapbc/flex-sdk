## Overview

This is a [Ruby on Rails](https://rubyonrails.org/) application. It includes:

- [U.S. Web Design System (USWDS)](https://designsystem.digital.gov/) for themeable styling and a set of common components
  - Custom USWDS form builder
- Integration with AWS services, including
  - Database integration with AWS RDS Postgresql using UUIDs
  - Active Storage configuration with AWS S3
  - Action Mailer configuration with AWS SES
  - Authentication with [devise](https://github.com/heartcombo/devise) and AWS Cognito
- Internationalization (i18n)
- Authorization using [pundit](https://github.com/varvet/pundit)
- Linting and code formatting using [rubocop](https://rubocop.org/)
- Testing using [rspec](https://rspec.info)

## 📂 Directory structure

As a Rails app, much of the directory structure is driven by Rails conventions. We've also included directories for common patterns, such as adapters, form objects and services.

**[Refer to the Software Architecture doc for more detail](../docs/{{app_name}}/software-architecture.md).**

Below are the primary directories to be aware of when working on the app:

```
├── app
│   ├── adapters         # External services
│   │   └── *_adapter.rb
│   ├── controllers
│   ├── forms            # Form objects
│   │   └── *_form.rb
│   ├── mailers
│   ├── models
│   │   └── concerns
│   ├── services         # Shared cross-model business logic
│   │   └── *_service.rb
│   └── views
├── db
│   ├── migrate
│   └── schema.rb
├── config
│   ├── locales          # i18n
│   └── routes.rb
├── spec                 # Tests
```

## 💻 Getting started with local development

### Prerequisites

- A container runtime (e.g. [Docker](https://www.docker.com/) or [Finch](https://github.com/runfinch/finch))
  - By default, `docker` is used. To change this, set the `CONTAINER_CMD` variable to `finch` (or whatever your container runtime is) in the shell.
- An AWS account with a Cognito User Pool and App Client configured
  - By default, the application configures authentication using AWS Cognito

### 💾 Setup

You can run the app within a container or natively. Each requires slightly different setup steps.

#### Environment variables

In either case, first generate a `.env` file:

1. Run `make .env` to create a `.env` file based on shared template.
1. Variables marked with `<FILL ME IN>` need to be manually set, and otherwise edit to your needs.

#### Running in a container

1. `make init-container`

#### Running natively

Prerequisites:

- Ruby 3.3.7
- [Node LTS](https://nodejs.org/en)
- (Optional but recommended): [rbenv](https://github.com/rbenv/rbenv)

Steps:

1. `make init-native`

### 🛠️ Development

#### Running the app

Once you've completed the setup steps above, you can run the site natively or within a container runtime.

To run within a container:

1. `make start-container`
1. Then visit http://localhost:3100

To run natively:

1. `make start-native`
1. Then visit http://localhost:3000

#### IDE tips

<details>
<summary>VS Code</summary>

##### Recommended extensions

- [Ruby LSP](https://marketplace.visualstudio.com/items?itemName=Shopify.ruby-lsp)
- [Simple ERB](https://marketplace.visualstudio.com/items?itemName=vortizhe.simple-ruby-erb), for tag autocomplete and snippets

</details>

## 📇 Additional reading

Beyond this README, you should also refer to the [`docs/{{app_name}}` directory](../docs/{{app_name}}) for more detailed info. Some highlights:

- [Technical foundation](../docs/{{app_name}}/technical-foundation.md)
- [Software architecture](../docs/{{app_name}}/software-architecture.md)
- [Authentication & Authorization](../docs/{{app_name}}/auth.md)
- [Internationalization (i18n)](../docs/{{app_name}}/internationalization.md)
- [Container images](../docs/{{app_name}}/container-images.md)
