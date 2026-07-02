# HashiCorpQ — Terraform Learning & Mastering (webIQ)

Single source of truth: docs/MASTER-RUNBOOK.html (open in a browser).

Modular, AWS Well-Architected Terraform for the webIQ AWS Organization.
Stage 1 deploys a FinOps-guardrailed foundation into the Infrastructure
account (715841359129), the Terraform execution seat.

Layout
  bootstrap/  One-time. Creates the S3 state bucket (ALREADY DONE in AWS).
  modules/    Reusable building blocks.
  live/       Deployable stacks. One state file per account/layer.
  scripts/    Pre-flight, WAF/CAF validation, FinOps, teardown.
  docs/       MASTER-RUNBOOK.html + this repo's reference.

Backend: S3 + native locking (use_lockfile, Terraform >= 1.11). No DynamoDB.
Profile: AWSAdministratorAccess-715841359129 (override with AWS_PROFILE).
