#!/usr/bin/env bash
# Lightweight FinOps posture check for Stage 1.
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh
P="--profile $AWS_PROFILE"

head "Budget configuration"
aws budgets describe-budget --account-id "$TARGET_ACCOUNT" --budget-name webiq-infra-monthly-budget $P \
  --query 'Budget.{Limit:BudgetLimit.Amount,Unit:BudgetLimit.Unit,Type:BudgetType,Period:TimeUnit}' --output table 2>/dev/null \
  && ok "budget readable" || warn "budget/API unavailable"

head "Managed resources in state (blast-radius view)"
if [ -d live/infrastructure/foundation/.terraform ]; then
  ( cd live/infrastructure/foundation && terraform state list 2>/dev/null | sed 's/^/      /' )
  n=$(cd live/infrastructure/foundation && terraform state list 2>/dev/null | wc -l)
  ok "$n resources under management"
else
  warn "foundation not initialized here (run terraform init first)"
fi

head "Cost hygiene reminder"
echo "      Stage 1 footprint is near-zero (S3 objects + params + a budget)."
echo "      When idle, run scripts/99-teardown.sh to destroy the foundation."
echo "      The state bucket persists (prevent_destroy) so you can redeploy."
summary
