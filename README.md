# CRMA-Sync
Utility for connecting to a specified Salesforce environment and fully syncing all CRMA objects

# Required Repository Settings
Create a Repository Secret called **SFDX_AUTH_URL_CI_PROD** (or similar for other environments, adapt the workflow script accordingly) and place the SFDX Auth URL token into it. You can generate this with the command **sf org display --verbose --json** (take the part starting with force:// ...)

Create several Repository Variables as well:
* API_VERSION (eg, 59.0)
* DEBUG_LOGGING (true or false)
* GIT_BRANCH (target branch to write to, defaults to main)
* GIT_USERNAME (the Github username to associate with the commit)
* GIT_EMAIL_ADDRESS (the Github email address to associate with the commit)
* OPTIONAL: SF_CLI_DOWNLOAD_URL (the URL for the SF CLI tarball, xz compressed)

# Example workflow action file
```
name: crma-sync-prod

on:
  workflow_dispatch:
  schedule:
  # run at 7AM every single day
  # https://crontab.guru <-- for generating CRON expression
    - cron: "0 7 * * *"

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: AtriumAI/CRMA-Sync@v2
        name: Sync-CRMA (Production)
        with:
          api-version: ${{ vars.API_VERSION }}
          git-branch: ${{ vars.GIT_BRANCH }}
          github-username: ${{ vars.GIT_USERNAME }}
          github-email: ${{ vars.GIT_EMAIL_ADDRESS }}
          sfdx-auth-url: ${{ secrets.SFDX_AUTH_URL_CI_PROD }}
          debug-logging: ${{ vars.DEBUG_LOGGING }}
          sf-download-url: ${{ vars.SF_CLI_DOWNLOAD_URL }} # Optional, will default to latest
```
