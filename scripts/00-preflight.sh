#!/usr/bin/env bash
# Validate the whole environment BEFORE any terraform command.
# Usage:  ./scripts/00-preflight.sh
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh

head "CLI tools"
for t in terraform aws gh jq git curl; do
  if command -v "$t" >/dev/null 2>&1; then ok "$t -> $(command -v "$t")"; else bad "$t missing"; fi
done

head "Terraform version (need >= 1.11 for native S3 locking)"
if command -v terraform >/dev/null 2>&1; then
  tv=$(terraform version -json 2>/dev/null | jq -r .terraform_version 2>/dev/null || terraform version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  ok "Terraform $tv"
  major=$(echo "$tv" | cut -d. -f1); minor=$(echo "$tv" | cut -d. -f2)
  if [ "$major" -gt 1 ] || { [ "$major" -eq 1 ] && [ "$minor" -ge 11 ]; }; then ok "version supports use_lockfile"; else bad "upgrade to >= 1.11"; fi
fi

head "AWS identity (profile: $AWS_PROFILE)"
ident=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --output json 2>/dev/null || true)
if [ -n "$ident" ]; then
  acct=$(echo "$ident" | jq -r .Account)
  arn=$(echo "$ident" | jq -r .Arn)
  if [ "$acct" = "$TARGET_ACCOUNT" ]; then ok "account $acct (target)"; else bad "account $acct != $TARGET_ACCOUNT"; fi
  echo "      $arn"
else
  bad "no AWS identity -- run: aws sso login --profile $AWS_PROFILE"
fi

head "GitHub"
if gh auth status >/dev/null 2>&1; then ok "gh authenticated ($(gh api user --jq .login 2>/dev/null || echo '?'))"; else warn "gh not authenticated (gh auth login)"; fi
if ssh -T git@github.com 2>&1 | grep -qi "successfully authenticated"; then ok "GitHub SSH ok"; else warn "GitHub SSH not verified"; fi

head "State backend"
if aws s3api head-bucket --bucket "$STATE_BUCKET" --profile "$AWS_PROFILE" >/dev/null 2>&1; then
  ok "state bucket exists: $STATE_BUCKET"
  echo "      => Bootstrap is DONE. Start at the FOUNDATION stack."
  if aws s3api head-object --bucket "$STATE_BUCKET" --key "$STATE_KEY" --profile "$AWS_PROFILE" >/dev/null 2>&1; then
    ok "foundation state present ($STATE_KEY) -- 'plan' should show 0 changes if already applied"
  else
    warn "no foundation state yet -- first 'apply' will create it"
  fi
else
  warn "state bucket NOT found -- run the BOOTSTRAP stack once (see runbook)"
fi

summary
