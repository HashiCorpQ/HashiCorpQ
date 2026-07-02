#!/usr/bin/env bash
# Post-DESTROY validation: proves foundation resources are GONE and that the
# state bucket correctly PERSISTS. Run this BETWEEN teardown and any re-apply.
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh
P="--profile $AWS_PROFILE"

head "Foundation resources should be ABSENT"

if aws s3api head-bucket --bucket "webiq-infra-artifacts-$TARGET_ACCOUNT" $P >/dev/null 2>&1; then
  bad "artifacts bucket STILL EXISTS (destroy incomplete or re-applied)"
else
  ok "artifacts bucket gone"
fi

if aws ssm get-parameter --name /webiq-infra/foundation/greeting $P >/dev/null 2>&1; then
  bad "SSM parameter STILL EXISTS"
else
  ok "SSM parameter gone"
fi

if aws budgets describe-budget --account-id "$TARGET_ACCOUNT" \
     --budget-name webiq-infra-monthly-budget $P >/dev/null 2>&1; then
  bad "budget STILL EXISTS"
else
  ok "budget gone"
fi

head "State backend should PERSIST (prevent_destroy)"
if aws s3api head-bucket --bucket "$STATE_BUCKET" $P >/dev/null 2>&1; then
  ok "state bucket still present (as intended)"
else
  bad "state bucket missing -- this should NEVER happen"
fi

head "Local state should list ZERO resources"
if [ -d live/infrastructure/foundation/.terraform ]; then
  n=$(cd live/infrastructure/foundation && terraform state list 2>/dev/null | wc -l)
  [ "$n" -eq 0 ] && ok "terraform state list is empty (0 resources)" || warn "$n resources still in state"
fi

summary
