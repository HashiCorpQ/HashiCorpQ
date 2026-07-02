#!/usr/bin/env bash
# Post-deploy validation against Well-Architected + CAF expectations.
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh
P="--profile $AWS_PROFILE"

check_bucket() {
  local b="$1" label="$2"
  head "SECURITY / RELIABILITY -- $label ($b)"
  aws s3api head-bucket --bucket "$b" $P >/dev/null 2>&1 && ok "exists" || { bad "missing"; return; }
  [ "$(aws s3api get-bucket-versioning --bucket "$b" $P --query Status --output text 2>/dev/null)" = "Enabled" ] \
    && ok "versioning enabled" || bad "versioning NOT enabled"
  aws s3api get-bucket-encryption --bucket "$b" $P >/dev/null 2>&1 \
    && ok "encryption at rest configured" || bad "no default encryption"
  local pab
  pab=$(aws s3api get-public-access-block --bucket "$b" $P --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,BlockPublicPolicy,IgnorePublicAcls,RestrictPublicBuckets]' --output text 2>/dev/null)
  [ "$pab" = "True	True	True	True" ] && ok "public access fully blocked" || bad "public access block incomplete ($pab)"
}

check_bucket "$STATE_BUCKET" "Terraform state bucket"
check_bucket "webiq-infra-artifacts-$TARGET_ACCOUNT" "Artifacts bucket (module)"

head "OPERATIONAL EXCELLENCE -- remote state + config"
aws s3api head-object --bucket "$STATE_BUCKET" --key "$STATE_KEY" $P >/dev/null 2>&1 \
  && ok "state stored remotely at $STATE_KEY" || bad "no remote state object"

head "OPERATIONAL EXCELLENCE -- stored parameter"
val=$(aws ssm get-parameter --name /webiq-infra/foundation/greeting $P --query Parameter.Value --output text 2>/dev/null || true)
[ -n "$val" ] && ok "SSM parameter readable: \"$val\"" || bad "SSM parameter missing"

head "COST OPTIMIZATION (FinOps) -- budget guardrail"
aws budgets describe-budget --account-id "$TARGET_ACCOUNT" --budget-name webiq-infra-monthly-budget $P >/dev/null 2>&1 \
  && ok "monthly budget exists with alert" || warn "budget not found (or budgets API perms)"

head "COST OPTIMIZATION -- cost-allocation tags"
tagcount=$(aws s3api get-bucket-tagging --bucket "webiq-infra-artifacts-$TARGET_ACCOUNT" $P --query 'length(TagSet)' --output text 2>/dev/null || echo 0)
[ "$tagcount" -ge 6 ] 2>/dev/null && ok "$tagcount cost-allocation tags on artifacts bucket" || warn "expected >=6 tags, found $tagcount"

summary
