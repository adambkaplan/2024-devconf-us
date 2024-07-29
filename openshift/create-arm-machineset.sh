#!/bin/bash

set -eu -o pipefail

infraID=$(oc get -o jsonpath="{.status.infrastructureName}" infrastructure cluster)

echo "Creating arm64 MachineSet for cluster ${infraID}"
machineRole=${MACHINE_ROLE:-worker}

awsRegion=$(oc get -o jsonpath="{.status.platformStatus.aws.region}" infrastructure cluster)
echo "AWS Region: ${awsRegion}"
awsAZ="${awsRegion}a"

machineAMI=$(oc get configmap/coreos-bootimages -n openshift-machine-config-operator -o jsonpath='{.data.stream}' |
jq -r '.architectures.aarch64.images.aws.regions."'"${awsRegion}"'".image')

echo "ARM Machine AMI: ${machineAMI}"

rm -rf "_output"
mkdir -p "_output"
output="_output/arm-machines-${infraID}.yaml"
cp -f arm-machines-template.yaml "${output}"

sed -i -E 's|\$INFRA_ID|'"${infraID}"'|g' "${output}"
sed -i -E 's|\$MACHINE_ROLE|'"${machineRole}"'|g' "${output}"
sed -i -E 's|\$REGION|'"${awsRegion}"'|g' "${output}"
sed -i -E 's|\$AWS_AZ|'"${awsAZ}"'|g' "${output}"
sed -i -E 's|\$MACHINE_AMI|'"${machineAMI}"'|g' "${output}"

echo "Creating ARM MachineSet"
oc apply -f "${output}"

echo "Waiting up to 10 minutes for machines to be ready"

oc wait --for=jsonpath='{.status.readyReplicas}'=1 --timeout=10m -f "${output}"
