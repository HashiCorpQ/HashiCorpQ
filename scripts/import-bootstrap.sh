#!/usr/bin/env bash
# Re-adopt the EXISTING state bucket into a fresh bootstrap state (new machine).
# Only needed if you want to manage the bucket from this machine. Optional.
cd "$(dirname "$0")/../bootstrap" || exit 1
source ../scripts/lib.sh
head "Importing existing state bucket into bootstrap state"
terraform init
terraform import aws_s3_bucket.tfstate "$STATE_BUCKET"
terraform import aws_s3_bucket_versioning.tfstate "$STATE_BUCKET"
terraform import aws_s3_bucket_server_side_encryption_configuration.tfstate "$STATE_BUCKET"
terraform import aws_s3_bucket_ownership_controls.tfstate "$STATE_BUCKET"
terraform import aws_s3_bucket_public_access_block.tfstate "$STATE_BUCKET"
ok "import complete -- 'terraform plan' should now show 0 changes"
