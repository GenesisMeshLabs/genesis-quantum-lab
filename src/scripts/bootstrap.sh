#!/usr/bin/env bash
# Safety-checked wrapper around `terraform init/plan/apply` for one of the
# environments under src/terraform/envs/*.
#
# Usage:
#   ./bootstrap.sh management plan
#   ./bootstrap.sh management apply
#   ./bootstrap.sh security plan
#   ./bootstrap.sh research plan
#
# Requires: terraform >= 1.6, AWS credentials for the target account already
# exported (AWS_PROFILE or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY/AWS_SESSION_TOKEN),
# and a terraform.tfvars in the target env directory (copy the .tfvars.example).

set -euo pipefail

ENV_NAME="${1:-}"
ACTION="${2:-plan}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="${SCRIPT_DIR}/../terraform/envs/${ENV_NAME}"

if [[ -z "${ENV_NAME}" || ! -d "${ENV_DIR}" ]]; then
  echo "Usage: $0 <management|security|research> <plan|apply|destroy>" >&2
  exit 1
fi

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "Missing ${ENV_DIR}/terraform.tfvars — copy terraform.tfvars.example and fill it in first." >&2
  exit 1
fi

echo "== Confirming caller identity =="
aws sts get-caller-identity

echo
echo "== terraform init (${ENV_NAME}) =="
terraform -chdir="${ENV_DIR}" init

case "${ACTION}" in
  plan)
    terraform -chdir="${ENV_DIR}" plan
    ;;
  apply)
    echo
    read -r -p "About to apply REAL infrastructure changes to account above. Type 'yes' to continue: " CONFIRM
    if [[ "${CONFIRM}" != "yes" ]]; then
      echo "Aborted."
      exit 1
    fi
    terraform -chdir="${ENV_DIR}" apply
    ;;
  destroy)
    echo
    read -r -p "About to DESTROY infrastructure in account above. Type 'yes' to continue: " CONFIRM
    if [[ "${CONFIRM}" != "yes" ]]; then
      echo "Aborted."
      exit 1
    fi
    terraform -chdir="${ENV_DIR}" destroy
    ;;
  *)
    echo "Unknown action: ${ACTION} (expected plan|apply|destroy)" >&2
    exit 1
    ;;
esac
