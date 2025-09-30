# Leaving a project

When Nava leaves a project, we will need to remove access to the private strata SDK repository. In order for the client project to continue functioning the client will need to have a copy of the strata SDK locally.

## Steps

1. Copy a version of the strata SDK to a directory within the host application e.g. in `app/engines/strata`
2. Update the Gemfile to point to the local copy of the strata SDK instead of the GitHub repository:

   ```ruby
   gem "strata", path: "engines/strata"
   ```
