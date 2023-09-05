#!/usr/bin/env bash
##
# Lint code.
#
# This is a router script to call relevant scripts based on type.
#
# shellcheck disable=SC2086
# shellcheck disable=SC2015

t=$(mktemp) && export -p >"$t" && set -a && . ./.env && if [ -f ./.env.local ]; then . ./.env.local; fi && set +a && . "$t" && rm "$t" && unset t

set -eu
[ "${DREVOPS_DEBUG-}" = "1" ] && set -x

# Linting types.
#
# Provide argument as 'be' or 'fe' to lint only back-end or front-end code.
# If no argument is provided, all code will be linted.
DREVOPS_LINT_TYPES="${DREVOPS_LINT_TYPES:-${1:-be-fe}}"

# Flag to skip code linting.
#
# Helpful to set in CI to skip code linting without modifying the codebase.
DREVOPS_LINT_SKIP="${DREVOPS_LINT_SKIP:-0}"

# ------------------------------------------------------------------------------

# @formatter:off
note() { printf "       %s\n" "$1"; }
info() { [ "${TERM:-}" != "dumb" ] && tput colors >/dev/null 2>&1 && printf "\033[34m[INFO] %s\033[0m\n" "$1" || printf "[INFO] %s\n" "$1"; }
pass() { [ "${TERM:-}" != "dumb" ] && tput colors >/dev/null 2>&1 && printf "\033[32m[ OK ] %s\033[0m\n" "$1" || printf "[ OK ] %s\n" "$1"; }
fail() { [ "${TERM:-}" != "dumb" ] && tput colors >/dev/null 2>&1 && printf "\033[31m[FAIL] %s\033[0m\n" "$1" || printf "[FAIL] %s\n" "$1"; }
# @formatter:on

[ "${DREVOPS_LINT_SKIP}" = "1" ] && note "Skipping code lint checks." && exit 0

if [ -z "${DREVOPS_LINT_TYPES##*be*}" ]; then
  ./scripts/drevops/lint-be.sh "$@"
fi

if [ -z "${DREVOPS_LINT_TYPES##*fe*}" ]; then
  ./scripts/drevops/lint-fe.sh "$@"
fi
