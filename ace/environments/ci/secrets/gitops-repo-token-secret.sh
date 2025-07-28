#!/usr/bin/env bash
set -eo pipefail

# ────────────────────────────────

: "${TOKEN_SECRET_NAME:?Please set TOKEN_SECRET_NAME when running script}"
: "${TOKEN:?Please set TOKEN when running script}"

# ───────────────────────────────
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTROLLER_NAME=${SEALED_SECRET_CONTROLLER_NAME:-sealed-secrets-controller}


envsubst < gitops-repo-token-secret-template.yaml |
kubeseal \
  --controller-name "${SEALED_SECRET_CONTROLLER_NAME}" \
  --controller-namespace "${SEALED_SECRET_NAMESPACE}" \
  --scope cluster-wide \
  --format yaml \
  > "github-user-token-secret-${TOKEN_SECRET_NAME}.yaml"

echo "✔︎ SealedSecret written to github-user-token-secret-${TOKEN_SECRET_NAME}.yaml"
