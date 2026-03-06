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

## Stimulus Controllers

Some Strata components (such as [conditional fields](strata-form-builder.md#conditional-conditional)) use [Stimulus](https://stimulus.hotwired.dev/) controllers for client-side interactivity. To enable these, register the Strata controllers with your Stimulus application.

The gem exposes a `registerControllers` function that registers all Strata Stimulus controllers at once. Import it and call it with your Stimulus application instance:

```js
import { Application } from "@hotwired/stimulus"
import { registerControllers } from "strata/index.js"

const application = Application.start()
registerControllers(application)
```

The gem's engine automatically adds its component assets to the asset load path, so `strata/index.js` is available without additional configuration.

If you prefer to register controllers individually:

```js
import { Application } from "@hotwired/stimulus"
import { ConditionalFieldComponentController } from "strata/index.js"

const application = Application.start()
application.register("strata--conditional-field", ConditionalFieldComponentController)
```
