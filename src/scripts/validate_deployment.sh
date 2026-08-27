#!/usr/bin/env bash
# Read-only validation against 02-Cloud-Infrastructure.md "Deployment Checklist".
# Run with credentials for the account you want to check (management or security).
#
# Usage: ./validate_deployment.sh

set -uo pipefail

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; }

echo "== Identity =="
aws sts get-caller-identity || { echo "No AWS credentials configured."; exit 1; }

echo
echo "== CloudTrail (multi-region, enabled) =="
TRAILS=$(aws cloudtrail describe-trails --query 'trailList[?IsMultiRegionTrail==true]' --output json 2>/dev/null)
if [[ "${TRAILS}" != "[]" && -n "${TRAILS}" ]]; then
  pass "Multi-region CloudTrail found"
  echo "${TRAILS}" | python3 -c "import json,sys; [print('   -', t['Name']) for t in json.load(sys.stdin)]" 2>/dev/null
else
  fail "No multi-region CloudTrail found"
fi

echo
echo "== GuardDuty =="
DETECTORS=$(aws guardduty list-detectors --query 'DetectorIds' --output text 2>/dev/null)
if [[ -n "${DETECTORS}" ]]; then
  pass "GuardDuty detector(s): ${DETECTORS}"
else
  fail "No GuardDuty detector found"
fi

echo
echo "== Security Hub =="
if aws securityhub describe-hub >/dev/null 2>&1; then
  pass "Security Hub enabled"
else
  fail "Security Hub not enabled"
fi

echo
echo "== AWS Config recorder =="
RECORDERS=$(aws configservice describe-configuration-recorder-status --query 'ConfigurationRecordersStatus[?recording==true]' --output json 2>/dev/null)
if [[ "${RECORDERS}" != "[]" && -n "${RECORDERS}" ]]; then
  pass "Config recorder is actively recording"
else
  fail "Config recorder not recording"
fi

echo
echo "== KMS keys tagged for this project =="
aws kms list-aliases --query "Aliases[?starts_with(AliasName, 'alias/meta-quantum-harvest')].AliasName" --output text 2>/dev/null

echo
echo "== S3 audit bucket Object Lock =="
BUCKET=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'meta-quantum-harvest-audit')].Name" --output text 2>/dev/null)
if [[ -n "${BUCKET}" ]]; then
  LOCK=$(aws s3api get-object-lock-configuration --bucket "${BUCKET}" --query 'ObjectLockConfiguration.ObjectLockEnabled' --output text 2>/dev/null)
  if [[ "${LOCK}" == "Enabled" ]]; then
    pass "Audit bucket ${BUCKET} has Object Lock enabled"
  else
    fail "Audit bucket ${BUCKET} found but Object Lock not enabled"
  fi
else
  fail "No meta-quantum-harvest-audit* bucket found"
fi

echo
echo "Checklist reference: 02-Cloud-Infrastructure.md 'Deployment Checklist'."
echo "Items this script cannot check automatically (manual/console-only):"
echo "  - IAM Identity Center configured + MFA enforced"
echo "  - Team trained on procedures"
