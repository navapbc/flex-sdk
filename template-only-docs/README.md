# Installation

## Prerequisites

This template requires the use of the [Rails template](https://github.com/navapbc/template-application-rails)

## Instructions

1. Since Flex SDK is a private gem, for use by non-Nava developers you'll need to create a personal access token (PAT) with read access to the contents of the `navapbc/flex-sdk` repository. Log into the `nava-platform-readonly` bot account and generate a fine-grained PAT for the project with read-only access to the `navapbc/flex-sdk` repository.
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

If you do not want to embed the token directly in the Gemfile, you will need to set the bundler environment variable `BUNDLE_GITHUB__COM` to the value of your PAT in your GitHub Actions workflows, in your local development environment and/or pass that environment variable into Docker when building the image.

Note this will set the credential that bundler uses to access _all_ GitHub repositories in Gemfile. So if the project needs to access multiple private GitHub repositories, ensure the user account used to generate the PAT is a resource owner to them all and select the appropriate repos when generating the PAT.

GitHub fine-grained PATs can also only be generated for a single resource owner at this time[1], so if the multiple private repositories do not cleanly map to a single resource owner you'll likely need to either:
1. Clone the relevant repos to a common org (or user), then keep it in sync with the upstream repo.
2. Use a classic PAT (understand the security implications).
3. Manually vendor the source code to your project and update the Gemfile to reference the project-local path.

[1] https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#fine-grained-personal-access-tokens-limitations
