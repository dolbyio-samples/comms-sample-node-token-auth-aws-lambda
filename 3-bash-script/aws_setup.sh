#!/bin/bash
set -e

while getopts n:p: flag
do
    case "${flag}" in
        name) NAME=${OPTARG};;
        region) REGION=${OPTARG};;
    esac
done

ARN_ROLE=$1
CONSUMER_KEY=$2
CONSUMER_SECRET=$3
if [ -z "$ARN_ROLE" ]
then
    echo "You need to provide the ARN for the Role you wish to use. Run create_fetch_token_iam_role.sh if you don't have one."
    exit
fi
if [ -z "$CONSUMER_KEY" ]
then
    echo "ERROR: Missing consumer key"
    exit
fi
if [ -z "$CONSUMER_SECRET" ]
then
    echo "ERROR: Missing consumer secret"
    exit
fi
if [ -z "$REGION" ]
then
    REGION="us-west-1"
else
    REGION=$REGION
fi
if [ -z "$NAME" ]
then
    NAME="fetchInteractivityToken"
else
    NAME=$NAME
fi
APINAME="${NAME}Api"


# Create the lamda function that uses the zipped up fetch_token.zip
echo "Creating the Lambda function ${NAME}"
aws lambda create-function --function-name "${NAME}" --zip-file fileb://fetch_token.zip --handler index.handler --runtime nodejs12.x --role ${ARN_ROLE} --region ${REGION}
# get ARN of lambda function just created
LAMBDAARN=$(aws lambda list-functions --query "Functions[?FunctionName==\`${NAME}\`].FunctionArn" --output text --region ${REGION})

echo "ARN of created lambda: ${LAMBDAARN}"
# Update environment variables of created lambda function with key and secret
echo "Setting consumer key and consumer secret environement variables of lambda function"
aws lambda update-function-configuration --function-name ${NAME} --environment 'Variables={CONSUMER_KEY='$CONSUMER_KEY',CONSUMER_SECRET='$CONSUMER_SECRET'}'

# Create the API Gateway
echo "Creating API Gateway"
aws apigateway create-rest-api --name "${APINAME}" --description "Api for ${NAME}"  --region ${REGION} --endpoint-configuration '{ "types": ["REGIONAL"] }'
# get ID of api just created
APIID=$(aws apigateway get-rest-apis --query "items[?name==\`${APINAME}\`].id" --output text --region ${REGION})
# get parent resource id of api
PARENTRESOURCEID=$(aws apigateway get-resources --rest-api-id ${APIID} --query 'items[?path==`/`].id' --output text --region ${REGION})

# Add the proxy resource to the API Gateway
echo "Adding proxy resource to API Gatway"
aws apigateway create-resource --rest-api-id ${APIID} --region ${REGION} --parent-id ${PARENTRESOURCEID} --path-part {proxy+} 
# get ID of resource just created
RESOURCEID=$(aws apigateway get-resources --rest-api-id ${APIID} --query 'items[?path==`/{proxy+}`].id' --output text --region ${REGION})


# Add GET as the method
echo "Adding the GET method"
aws apigateway put-method --rest-api-id ${APIID} --region ${REGION} --resource-id ${RESOURCEID} --http-method ANY --authorization-type "NONE"


# Configure integration with type: aws_proxy
echo "Configuring gateway integration with type: aws_proxy"
aws apigateway put-integration \
        --region ${REGION} \
        --rest-api-id ${APIID} \
        --resource-id ${RESOURCEID} \
        --http-method ANY \
        --type AWS_PROXY \
        --integration-http-method POST \
        --uri arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDAARN}/invocations


# Deploy Gateway
echo "Deploying Gateway"
aws apigateway create-deployment \
--rest-api-id ${APIID} \
--stage-name prod \
--region ${REGION}

# Create permissions for gateway to invoke lambda function
echo "Creating permissions for gateway to invoke lambda function"
APIARN=$(echo ${LAMBDAARN} | sed -e 's/lambda/execute-api/' -e "s/function:${NAME}/${APIID}/")
aws lambda add-permission \
--function-name ${NAME} \
--statement-id apigateway-token-test \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com \
--source-arn "${APIARN}/*/{proxy+}" \
--region ${REGION}

aws lambda add-permission \
--function-name ${NAME} \
--statement-id apigateway-token-prod \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com \
--source-arn "${APIARN}/prod/{proxy+}" \
--region ${REGION}

echo "Invoke URL to use to GET interactivity access token:
https://${APIID}.execute-api.${REGION}.amazonaws.com/prod/token"