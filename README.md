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
