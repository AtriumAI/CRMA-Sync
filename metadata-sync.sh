#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset
export PATH=$(pwd)/node_modules/.bin:$PATH
sf version

# Salesforce Org Credentials
ORG_ALIAS="SFOrg"

# Git Repository Settings
GIT_REPO_PATH=$(pwd)  # Path to Repo on local machine
GIT_BRANCH="main"

# Salesforce Metadata Types to Retrieve
METADATA_TYPES=("WaveApplication" "WaveDashboard" "WaveDataflow" "WaveDataset" "WaveLens" "WaveRecipe" "WaveTemplateBundle" "WaveXmd")

# Salesforce CLI Login
echo "Logging in to Salesforce org..."
echo $SFDX_AUTH_URL > sfdx_auth.txt
sf org login sfdx-url --sfdx-url-file sfdx_auth.txt --set-default --alias $ORG_ALIAS
rm sfdx_auth.txt

# Check if API_VERSION was specified
if [[ $API_VERSION != '' ]]; then
  echo "INFO: API_VERSION $API_VERSION specified. will use that unless overridden by sfdx-project.json sourceApiVersion"
  API_VERSION="--api-version $API_VERSION"
else
  echo "WARN: API_VERSION not specified. Will use sourceApiVersion from sfdx-project.json, or current latest API version if that is unavailable"
fi

cd $GIT_REPO_PATH
git pull

# Retrieve Metadata from Salesforce Org
for TYPE in "${METADATA_TYPES[@]}"; do
  echo "Retrieving $TYPE metadata..."
  sf project retrieve start --metadata "$TYPE" $API_VERSION
done

# Git Commit and Push
##echo "Adding changes to Git..."
git -C "$GIT_REPO_PATH" add .
git -C "$GIT_REPO_PATH" commit -m "Update Salesforce metadata - $(date)"
git -C "$GIT_REPO_PATH" push origin "$GIT_BRANCH"

# Salesforce CLI Logout
echo "Logging out from Salesforce org..."
sf org logout --target-org $ORG_ALIAS --no-prompt

echo "Script completed successfully!"
