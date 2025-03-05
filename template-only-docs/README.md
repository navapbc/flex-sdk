# Installation

## Prerequisites

This template requires the use of the [Rails template](https://github.com/navapbc/template-application-rails)

## Instructions

1. Install this template using the [nava-platform CLI](https://github.com/navapbc/platform-cli) using the same `<APP_NAME>` that you used to install the Rails template.
2. Add the following to your `Gemfile`:

    ```ruby
    # Flex Government Digital Services SDK Rails engine
    gem "flex", path: "engines/flex"
    ```

3. Update `<APP_NAME>/Dockerfile` to include `COPY ./engines ./engines` to the Docker image before the `RUN bundle install`. The Dockerfile should look like this:

    ```dockerfile
    # Install application gems for production
    COPY Gemfile Gemfile.lock ./
    COPY ./engines ./engines
    RUN bundle config set --local without development test && \
        bundle install && \
        rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
    ```
