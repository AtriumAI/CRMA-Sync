#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset
export PATH=$(pwd)/node_modules/.bin:$PATH
if [[ $DEBUG_LOGGING ]]; then
  sf version
fi

# Salesforce Org Credentials
ORG_ALIAS="SFOrg"

# Git Repository Settings
GIT_REPO_PATH=$(pwd)  # Path to Repo on local machine

# Salesforce Metadata Types to Retrieve
METADATA_TYPES=("WaveApplication" "WaveDashboard" "WaveDataflow" "WaveDataset" "WaveLens" "WaveRecipe" "WaveTemplateBundle" "WaveXmd")

# Salesforce CLI Login
if [[ $DEBUG_LOGGING ]]; then
  echo "Logging in to Salesforce org..."
fi
echo $SFDX_AUTH_URL > sfdx_auth.txt
sf org login sfdx-url --sfdx-url-file sfdx_auth.txt --set-default --alias $ORG_ALIAS
rm sfdx_auth.txt

# Check if API_VERSION was specified
if [[ $API_VERSION != '' ]]; then
  if [[ $DEBUG_LOGGING ]]; then
    echo "INFO: API_VERSION $API_VERSION specified. will use that unless overridden by sfdx-project.json sourceApiVersion"
  fi
  API_VERSION="--api-version $API_VERSION"
else
  echo "WARN: API_VERSION not specified. Will use sourceApiVersion from sfdx-project.json, or current latest API version if that is unavailable"
fi

# Set up Git
git config --global user.email $GITHUB_EMAIL
git config --global user.name $GITHUB_USERNAME

cd $GIT_REPO_PATH
git pull

# Retrieve Metadata from Salesforce Org
for TYPE in "${METADATA_TYPES[@]}"; do
  if [[ $DEBUG_LOGGING ]]; then
    echo "INFO: Retrieving $TYPE metadata..."
  fi
  sf project retrieve start --json --metadata "$TYPE" $API_VERSION
done

# Git Commit and Push
echo "Adding changes to Git (Branch: $GIT_BRANCH)..."
git -C "$GIT_REPO_PATH" add .
git -C "$GIT_REPO_PATH" commit -m "Update CRMA metadata - $(date)"
git -C "$GIT_REPO_PATH" push origin "$GIT_BRANCH"

# Salesforce CLI Logout
if [[ $DEBUG_LOGGING ]]; then
  echo "Logging out from Salesforce org..."
fi
sf org logout --target-org $ORG_ALIAS --no-prompt

echo "Script completed successfully!"
