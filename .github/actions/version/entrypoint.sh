#!/bin/bash
set -euo pipefail

semver="$INPUT_SEMVER"
default_branch="$INPUT_DEFAULT_BRANCH"
debug="${INPUT_DEBUG:-false}"

debug_log() {
  if [ "$debug" = "true" ]; then
    echo "##[debug]$1"
  fi
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

debug_log "semver=$semver"
debug_log "default_branch=$default_branch"

exists=$(check_git_tag_exists "$semver")

{
  echo "semver=$semver"
  echo "major=$(parse_semver_component "$semver" 1)"
  echo "minor=$(parse_semver_component "$semver" 2)"
  echo "patch=$(parse_semver_component "$semver" 3)"
  echo "tag-exists=$exists"
  echo "releasable=$( [ "$GITHUB_REF" == "refs/heads/${default_branch}" ] && [ "$exists" == "false" ] && echo "true" || echo "false" )"
} >> "$GITHUB_OUTPUT"

debug_log "GitHub Output: $(cat "$GITHUB_OUTPUT")"
