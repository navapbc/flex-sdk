# Installation

## Prerequisites

This template requires the use of the [Rails template](https://github.com/navapbc/template-application-rails)

## Instructions

1. Add the following to your `Gemfile`:

    ```ruby
    # Strata Government Digital Services SDK Rails engine
    gem "strata", git: "https://github.com/navapbc/strata-sdk-rails.git"
    ```

1. Run `bundle install` to install the gem and its dependencies.

## JavaScript Assets

The Strata engine automatically configures JavaScript assets for your application. How this works depends on your asset pipeline setup.

### Importmap (recommended)

If your application uses [`importmap-rails`](https://github.com/rails/importmap-rails), the Strata engine **automatically registers its importmap pins** with your application. No manual pin configuration is needed — the engine sweeps its own `config/importmap.rb` into your app's importmap at boot time.

This follows the same auto-sweep pattern used by Rails engines like `turbo-rails` and `stimulus-rails`.

### Sprockets / Propshaft (asset precompilation)

If your application uses Sprockets or Propshaft, the Strata engine **automatically adds its component directory to the asset load path** and **precompiles all Strata JS files**. No manual asset configuration is needed.

## Stimulus Controllers

Some Strata components (such as [conditional fields](strata-form-builder.md#conditional-conditional)) use [Stimulus](https://stimulus.hotwired.dev/) controllers for client-side interactivity. To enable these, register the Strata controllers with your Stimulus application.

The gem exposes a `registerControllers` function that registers all Strata Stimulus controllers at once. Import it and call it with your Stimulus application instance:

```js
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "strata"

const application = Application.start()
registerControllers(application)
```

If you prefer to register controllers individually:

```js
import { Application } from "@hotwired/stimulus"
import { ConditionalFieldComponentController } from "strata"

const application = Application.start()
application.register("strata--conditional-field", ConditionalFieldComponentController)
```

> **Note:** The import path is `"strata"` (not `"strata/index.js"`). The engine's importmap pins `"strata"` to the correct JS entry point automatically. If your app does not use `importmap-rails`, you can import from `"strata/index.js"` directly since the engine adds the component directory to the asset load path.
