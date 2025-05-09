# Installation

## Prerequisites

This template requires the use of the [Rails template](https://github.com/navapbc/template-application-rails)

## Instructions

1. Since Flex SDK is a private gem, you need to create a personal access token (PAT) with read access to the contents of the navapbc/flex-sdk repository.
2. Add the following to your `Gemfile` using the PAT you created in step 1:

    ```ruby
    # Flex Government Digital Services SDK Rails engine
    gem "flex", git: "https://<PERSONAL_ACCESS_TOKEN>:x-oauth-basic@github.com/navapbc/flex-sdk.git"
    ```

3. If using the infrastructure template, this token will trigger a vulnerability scan error in Trivy. You'll want to update trivy-secret.yml and add the following entry to ignore this token.

    ```yml
    - id: flex-sdk-pat
      description: Skip personal access token to access Flex SDK Gem from navapbc/flex-sdk
      regex: <PERSONAL_ACCESS_TOKEN>
      path: /rails/Gemfile
    ```

If you do not want to embed the token directly in the Gemfile, you will need to set the bundler environment variable `BUNDLE_GITHUB__COM` to the value of your PAT in your GitHub Actions workflows and also pass that environment variable into Docker when building the image.
