#! /bin/bash
for i in `seq 1 30`; do
    aws lambda invoke --function-name ${CHECK_FUNCTION_NAME} --region ap-southeast-1 --payload '{ "type": "fetch", "name": "'"${DEPLOYMENT_NAME}"'" }' response.json > /dev/null
    export DEPLOYED_TAG=$(cat response.json)
    echo "Checking..."
    if [ "${DEPLOYED_TAG:1:-1}" == "${DEPLOYMENT_IMAGE_TAG}" ]; then
        echo "Deployment is complete!";
        exit 0
    fi
    echo "Deployment is not ready!"
    rm response.json
    sleep 30;
done
