#!/usr/bin/env bash
# Safe teardown: destroys the FOUNDATION stack only. State bucket is preserved.
cd "$(dirname "$0")/.." || exit 1
source scripts/lib.sh
head "Teardown -- foundation stack"
echo "  This destroys resources in live/infrastructure/foundation ONLY."
echo "  The state bucket ($STATE_BUCKET) is NOT touched."
read -r -p "  Type 'destroy' to proceed: " ans
[ "$ans" = "destroy" ] || { warn "aborted"; exit 0; }
cd live/infrastructure/foundation
terraform destroy
