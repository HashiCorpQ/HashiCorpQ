#!/usr/bin/env bash
# Shared helpers for HashiCorpQ scripts. Source, don't execute.
set -uo pipefail

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YEL=$'\033[0;33m'; BLU=$'\033[0;36m'; NC=$'\033[0m'
PASS=0; FAIL=0; WARN=0

ok()   { echo "${GREEN}  ✓${NC} $*"; PASS=$((PASS+1)); }
bad()  { echo "${RED}  ✗${NC} $*";   FAIL=$((FAIL+1)); }
warn() { echo "${YEL}  !${NC} $*";   WARN=$((WARN+1)); }
head() { echo; echo "${BLU}== $* ==${NC}"; }

# Project constants (edit here only)
export AWS_PROFILE="${AWS_PROFILE:-AWSAdministratorAccess-715841359129}"
export TARGET_ACCOUNT="715841359129"
export REGION="us-east-1"
export STATE_BUCKET="webiq-tfstate-715841359129-us-east-1"
export STATE_KEY="infrastructure/foundation/terraform.tfstate"

summary() {
  echo
  echo "${BLU}---------------------------------------------${NC}"
  echo "  ${GREEN}PASS:${NC} $PASS   ${YEL}WARN:${NC} $WARN   ${RED}FAIL:${NC} $FAIL"
  echo "${BLU}---------------------------------------------${NC}"
  [ "$FAIL" -eq 0 ]
}
