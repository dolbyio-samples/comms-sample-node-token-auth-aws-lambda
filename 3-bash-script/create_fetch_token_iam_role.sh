#!/bin/bash
set -e
ROLE_ARN=$(aws iam list-roles --query 'Roles[?RoleName==`FetchInteractivityTokenRole`].Arn' --output text)
if ! [ -z "$ROLE_ARN" ]
then
    echo "An existing role called FetchInteractivityTokenRole was found. The ARN for this is:
${ROLE_ARN}"
else
echo "No existing role called FetchInteractivityTokenRole was found. Creating a new role ..."
# create exectution role
aws iam create-role --role-name FetchInteractivityTokenRole --assume-role-policy-document file://trust-policy.json
# add permissions to role
aws iam attach-role-policy --role-name FetchInteractivityTokenRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
# get the role ARN
ROLE_ARN=$(aws iam get-role --role-name "FetchInteractivityTokenRole" --query Role.Arn --output text)

echo "Created a new role called FetchInteractivityTokenRole. The ARN for this is: ${ROLE_ARN}"
fi