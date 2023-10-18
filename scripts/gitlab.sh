#!/bin/bash

GITLAB_API_URL="https://gitlab.com/api/v4"
GITLAB_PROJECT_ID="$1"

function gitlab_api() {
  GITLAB_USER_URL=${GITLAB_API_URL/%/\/user}
  GITLAB_PROJECT_URL=${GITLAB_API_URL/%/\/projects\/${GITLAB_PROJECT_ID}}  

  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_USER_URL}" | jq -r '.username'
  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_PROJECT_URL}" | jq -r '.http_url_to_repo'
  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_PROJECT_URL}" | jq .
}

gitlab_api

