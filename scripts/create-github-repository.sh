#!/bin/bash

# Exit on fail
set -euo pipefail

# Github variables
GITHUB_URL="https://github.com"
GITHUB_API_URL=${GITHUB_URL/https:\/\//https:\/\/api.}
GITHUB_ORG="to-ge-da"
REPOSITORY_VISIBILITY="private"
#GITHUB_TEAM_IDS=(iberia-customer-commercial-ancillaries iberia-software-engineering-tech-leads)
#GITHUB_TEAM_PERMISSIONS=(maintain admin)

# Check the requested repository in github org using REST API.
function github_org_check_repository() {
  HTTP_STATUS=$(curl -sI \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_AUTH_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${GITHUB_API_URL}/repos/${GITHUB_ORG}/${GITHUB_PROJECT_NAME}" | grep 'HTTP' | awk '{print $2}')
}

# Create a new repository in the github org using REST API.
function github_org_create_repository() {
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_AUTH_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -d "{
         \"name\": \"${GITHUB_PROJECT_NAME}\",
         \"auto_init\": \"true\",
         \"visibility\": \"${REPOSITORY_VISIBILITY}\"
       }" \
    "${GITHUB_API_URL}/orgs/${GITHUB_ORG}/repos" \
    -o /dev/null
}

# Add teams for in the new repository organization using REST API.
#function github_org_add_teams() {
#  for ((i=0;i<${#GITHUB_TEAM_IDS[@]};i++)); do
#    curl \
#      -X PUT \
#      -H "Accept: application/vnd.github+json" \
#      -H "Authorization: Bearer ${GITHUB_AUTH_TOKEN}" \
#      -H "X-GitHub-Api-Version: 2022-11-28" \
#      -s "${GITHUB_API_URL}/orgs/${GITHUB_ORG}/teams/${GITHUB_TEAM_IDS[i]}/repos/${GITHUB_ORG}/${GITHUB_PROJECT_NAME}" \
#      -d "{\"permission\":\"${GITHUB_TEAM_PERMISSIONS[i]}\"}"
#  done
#}

function main() {
  if [ "$#" -lt 2 ]; then
    echo "Missing arguments."
    exit 1
  else
    REPOSITORY_NAME="$1"
    REPOSITORY_TYPE="$2"
    GITHUB_PROJECT_NAME="$REPOSITORY_NAME-$REPOSITORY_TYPE"
    # Call the github_check_repository function and store the result in HTTP_STATUS variable.
    github_org_check_repository

    case "$HTTP_STATUS" in
      404)
        # If the requested repository does not exist, so create a new one.
        printf "Repository sucessfully created in %s/%s\n" "$GITHUB_ORG" "$GITHUB_PROJECT_NAME"
        github_org_create_repository
        ;;
      401)
        # Error, the supplied credentials are invalid, exit.
        printf "Invalid credentials!\n"
        exit 0
        ;;
      301)
        # Permanent redirection, exit.
        printf "Permanent redirection location.\n"
        exit 0
        ;;
      200)
        # The requested repository already exists, exit.
        printf "The repository already exists.\n"
        exit 0
        ;;
    esac

  fi
}

main "$@"
