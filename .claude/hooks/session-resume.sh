#!/usr/bin/env bash

# SessionStart hook for resume, clear, and compact events.
# Responsibilities:
# - persist repo-local PATH entries for later Claude Bash commands
# - surface lightweight repo context only
# - avoid launching GUI apps or mutating the environment aggressively

set -u

ROOT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
WEB_ROOT="${DRUPAL_WEB_ROOT:-}"
if [ -z "${WEB_ROOT}" ]; then
  for candidate in docroot web html; do
    if [ -d "${ROOT_DIR}/${candidate}/themes/custom" ]; then
      WEB_ROOT="${ROOT_DIR}/${candidate}"
      break
    fi
  done
elif [ "${WEB_ROOT#/}" = "${WEB_ROOT}" ]; then
  WEB_ROOT="${ROOT_DIR}/${WEB_ROOT}"
fi

THEME_ROOT="${DRUPAL_THEME_ROOT:-}"
if [ -z "${THEME_ROOT}" ]; then
  THEME_ROOT="${WEB_ROOT:-${ROOT_DIR}/docroot}/themes/custom"
fi
if [ -n "${THEME_ROOT}" ] && [ "${THEME_ROOT#/}" = "${THEME_ROOT}" ]; then
  THEME_ROOT="${ROOT_DIR}/${THEME_ROOT}"
fi
EXPECTED_THEME_DIR=""
if [ -d "${THEME_ROOT}" ]; then
  EXPECTED_THEME_DIR="$(find "${THEME_ROOT}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)"
fi

print_line() {
  printf '%s\n' "$1"
}

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  # Persist PATH updates so future Claude Bash commands can use local binaries.
  printf 'export PATH="$PATH:%s/node_modules/.bin"\n' "${ROOT_DIR}" >> "${CLAUDE_ENV_FILE}"
  if [ -d "${EXPECTED_THEME_DIR}/node_modules/.bin" ]; then
    printf 'export PATH="$PATH:%s/node_modules/.bin"\n' "${EXPECTED_THEME_DIR}" >> "${CLAUDE_ENV_FILE}"
  fi
fi

if [ ! -f "${ROOT_DIR}/CLAUDE.md" ]; then
  print_line "Notice: CLAUDE.md not found in current directory"
fi

if git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH="$(git -C "${ROOT_DIR}" rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'unknown')"
  DEFAULT_BRANCH="$(git -C "${ROOT_DIR}" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
  DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
  STATUS_LINES="$(git -C "${ROOT_DIR}" status --short 2>/dev/null | sed -n '1,5p')"
  STATUS_COUNT="$(git -C "${ROOT_DIR}" status --short 2>/dev/null | wc -l | tr -d ' ')"

  if [ "${BRANCH}" != "${DEFAULT_BRANCH}" ]; then
    print_line "Branch: ${BRANCH}"
  fi

  if [ "${STATUS_COUNT}" -gt 0 ]; then
    print_line "Git changes: ${STATUS_COUNT}"
    if [ -n "${STATUS_LINES}" ]; then
      printf '%s\n' "${STATUS_LINES}"
    fi
  fi
fi

if [ -z "${EXPECTED_THEME_DIR}" ]; then
  print_line "Notice: no theme found under ${THEME_ROOT}"
fi
