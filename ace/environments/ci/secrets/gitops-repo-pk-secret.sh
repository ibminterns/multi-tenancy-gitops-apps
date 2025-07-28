#!/usr/bin/env bash
set -eo pipefail

# 1. Ensure required env vars are set
: "${GITOPS_PK_SECRET_NAME:?Please set GITOPS_PK_SECRET_NAME}"
: "${GIT_BASEURL:?Please set GIT_BASEURL}"
: "${SSH_PRIVATE_KEY_PATH:?Please set SSH_PRIVATE_KEY_PATH}"

# 2. Allow overrides for controller location
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTROLLER_NAME=${SEALED_SECRET_CONTROLLER_NAME:-sealed-secrets-controller}

# 3. Build → seal → output
oc create secret generic "${GITOPS_PK_SECRET_NAME}" \
  --from-file=id_rsa="${SSH_PRIVATE_KEY_PATH}" \
  --from-literal=known_hosts="$(ssh-keyscan ${GIT_BASEURL} 2>/dev/null)" \
  --type kubernetes.io/ssh-auth \
  --dry-run=client -o yaml |
  oc label -f- created-by=pipeline --local --dry-run=client -o yaml |
  kubeseal \
    --controller-name "${SEALED_SECRET_CONTROLLER_NAME}" \
    --controller-namespace "${SEALED_SECRET_NAMESPACE}" \
    --scope cluster-wide \
    --format yaml \
    > "git-ssh-pk-${GITOPS_PK_SECRET_NAME}.yaml"