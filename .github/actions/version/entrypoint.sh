#!/bin/bash
set -euo pipefail

debug_log() {
  if [ "${RUNNER_DEBUG:-0}" = "1" ]; then
    echo "$1" | while IFS= read -r line; do
      echo "##[debug]$line"
    done
  fi
}

log_content() {
  local content="$1"
  local label="${2:-}"

  if [[ -n "$label" ]]; then
    # Replace the beginning of each line with two spaces
    local indented_content="${content//$'\n'/$'\n'  }"
    printf "%s:\n  %s\n" "$label" "$indented_content"
  else
    echo "$content"
  fi
}

log_output() {
  echo ::group::Set outputs
  log_content "$(cat "$GITHUB_OUTPUT")" "GITHUB_OUTPUT"
  log_content "$(cat "$GITHUB_ENV")" "GITHUB_ENV"
  echo ::endgroup::
}

set_output() {
  local value="$1"
  local output_key="$2"
  local env_key="${3:-}"

  if [ -z "$value" ] || [ -z "$output_key" ]; then
    echo "Missing essential arguments to set_output_and_env"
    return 1
  fi

  # If env_key is empty, convert output_key to upper snake case
  if [ -z "$env_key" ]; then
    env_key=$(echo "$output_key" | awk '{print toupper($0)}' | sed 's/-/_/g')
  fi

  echo "$output_key=$value" >> "$GITHUB_OUTPUT"
  echo "$env_key=$value" >> "$GITHUB_ENV"
}

parse_semver_component() {
  component=$(echo "$1" | cut -f"$2" -d.)
  if [ -z "$component" ]; then
    echo "Could not parse version: $1"
    exit 1
  fi
  echo "$component"
}

check_git_tag_exists() {
  git fetch --prune --unshallow --tags > /dev/null || {
    echo "Failed to fetch git tags. Make sure 'actions/checkout' was used before this action."
    exit 1
  }
  git show-ref --tags "v$1" --quiet && echo "true" || echo "false"
}

default_branch="$INPUT_DEFAULT_BRANCH"; debug_log "default_branch=$default_branch"
ref=$GITHUB_REF; debug_log "ref=$ref"
semver="$INPUT_SEMVER"; debug_log "semver=$semver"
tag_exists=$(check_git_tag_exists "$semver"); debug_log "tag_exists=$tag_exists"
releasable="$( [ "$ref" == "refs/heads/${default_branch}" ] && [ "$tag_exists" == "false" ] && echo "true" || echo "false" )"
debug_log "releasable=$releasable"

set_output "$semver" "semver"
set_output "$(parse_semver_component "$semver" 1)" "major"
set_output "$(parse_semver_component "$semver" 2)" "minor"
set_output "$(parse_semver_component "$semver" 3)" "patch"
set_output "$tag_exists" "tag-exists"
set_output "$releasable" "releasable"
log_output
