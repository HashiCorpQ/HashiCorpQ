#!/usr/bin/env bash
# Full inventory of everything this project manages -- for identification.
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh
P="--profile $AWS_PROFILE"

head "Terraform-managed resources (per stack)"
for d in bootstrap live/infrastructure/foundation live/infrastructure/github-oidc; do
  if [ -d "$d/.terraform" ]; then
    echo "  ${BLU}$d${NC}"
    ( cd "$d" && terraform state list 2>/dev/null | sed 's/^/      /' )
  else
    warn "$d not initialized (terraform init to inventory)"
  fi
done

head "Live AWS resources tagged Project=HashiCorpQ"
echo "  S3 buckets:"
aws s3api list-buckets $P --query 'Buckets[?starts_with(Name,`webiq`)].Name' --output text 2>/dev/null | tr '\t' '\n' | sed 's/^/      /'
echo "  SSM parameters:"
aws ssm describe-parameters $P --query "Parameters[?starts_with(Name,'/webiq-infra')].Name" --output text 2>/dev/null | tr '\t' '\n' | sed 's/^/      /'
echo "  Budgets:"
aws budgets describe-budgets --account-id "$TARGET_ACCOUNT" $P --query 'Budgets[].BudgetName' --output text 2>/dev/null | tr '\t' '\n' | sed 's/^/      /'
echo "  IAM roles (gha-*):"
aws iam list-roles $P --query "Roles[?starts_with(RoleName,'gha-')].RoleName" --output text 2>/dev/null | tr '\t' '\n' | sed 's/^/      /'
echo
ok "inventory complete"
