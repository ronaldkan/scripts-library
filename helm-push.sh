#! /bin/bash
helm package .
export HELM_CHART_VERSION=${HELM_VERSION}
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT}
helm push ${HELM_CHART_NAME}-${HELM_VERSION}.tgz oci://${AWS_ACCOUNT}/${HELM_TAG}/
