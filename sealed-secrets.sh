#!/bin/bash
export AWS_ACCESS_KEY_ID=$bamboo_custom_aws_accessKeyId
export AWS_SECRET_ACCESS_KEY=$bamboo_custom_aws_secretAccessKey_password
export AWS_SESSION_TOKEN=$bamboo_custom_aws_sessionToken_password
export AWS_DEFAULT_REGION="ap-southeast-1"

export BUILD_PATH=$(pwd)
export PATH=$BUILD_PATH/bin:$PATH

# download aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i $BUILD_PATH/extras/aws-cli -b $BUILD_PATH/bin

# download kubeseal cli
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.5/kubeseal-linux-amd64 -O kubeseal
chmod 755 kubeseal
mv kubeseal $BUILD_PATH/bin

# download jq
wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq
chmod 755 jq
mv jq $BUILD_PATH/bin

# check binaries version
echo "***** Checking binaries version *****"
aws --version
kubeseal --version
jq --version


SECRETS_LENGTH=$(aws secretsmanager list-secrets | jq ".SecretList | length")
LOOP_LENGTH=$((SECRETS_LENGTH - 1))

# Retrieve certificate for kubeseal
SECRET_CERT=$(aws secretsmanager get-secret-value --secret-id ${bamboo.controller_cert} --query SecretString --output text)
echo -e "$SECRET_CERT" >> dir/sealed-secrets-controller.crt

# generate 
for index in $(seq 0 $LOOP_LENGTH)
do
  SECRET_NAME=$(aws secretsmanager list-secrets | jq ".SecretList" | jq -r ".[$index].Name")
	SECRET="$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" | jq -r ".SecretString")"
	echo -e "$SECRET" >> dir/$SECRET_NAME.json
	kubeseal --cert dir/sealed-secrets-controller.crt < dir/$SECRET_NAME.json > dir/$SECRET_NAME-sealed.yaml
	mv dir/$SECRET_NAME-sealed.yaml sealedsecrets/$SECRET_NAME-sealed.yaml
	git add sealedsecrets/$SECRET_NAME-sealed.yaml
	rm -f dir/$SECRET_NAME.json
done