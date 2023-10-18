#!/bin/bash

GITLAB_API_URL="https://gitlab.com/api/v4/projects"
GITLAB_PROJECT_ID="$1"

function check_gitlab_repository() {
  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_API_URL}/${GITLAB_PROJECT_ID}" | jq -r '.owner.username'
  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_API_URL}/${GITLAB_PROJECT_ID}" | jq -r '.http_url_to_repo'
  curl -H "PRIVATE-TOKEN: ${GITLAB_AUTH_TOKEN}" -s "${GITLAB_API_URL}/${GITLAB_PROJECT_ID}" | jq .
}

check_gitlab_repository
