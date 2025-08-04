#!/usr/bin/env bash

set -eo pipefail

# Check variables
if [ -z ${IBM_ENTITLEMENT_KEY} ]; then
  echo "Please set IBM_ENTITLEMENT_KEY when running script"
  exit 1
fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-kube-system}
SEALED_SECRET_CONTROLLER_NAME=${SEALED_SECRET_CONTROLLER_NAME:-sealed-secrets-controller}

oc create secret docker-registry \
  ibm-entitlement-key \
  --docker-username=cp \
  --docker-server=cp.icr.io \
  --docker-password=${IBM_ENTITLEMENT_KEY} \
  --dry-run=client -o yaml \
  | oc label -f- \
    created-by=pipeline \
    --local \
    --dry-run=client -o yaml \
  | kubeseal \
    --scope cluster-wide \
    --controller-name=${SEALED_SECRET_CONTROLLER_NAME} \
    --controller-namespace=${SEALED_SECRET_NAMESPACE} \
    -o yaml > ibm-entitlement-key-secret.yaml