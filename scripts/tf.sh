#!/usr/bin/env bash
# Run terraform in a named stack from anywhere: ./scripts/tf.sh foundation plan
cd "$(dirname "$0")/.." || exit 1
stack="$1"; shift
case "$stack" in
  foundation) d="live/infrastructure/foundation" ;;
  oidc)       d="live/infrastructure/github-oidc" ;;
  bootstrap)  d="bootstrap" ;;
  *) echo "unknown stack: $stack (foundation|oidc|bootstrap)"; exit 1 ;;
esac
cd "$d" && terraform "$@"
