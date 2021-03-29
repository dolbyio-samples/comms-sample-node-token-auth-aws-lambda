# Token Server with AWS Services

This contains the complete sample code that accompanies the Dolby.io blog post Token Server with AWS Services by Katie Gray.

Each numbered section corresponds to sections in the blog post. For more details on each section, please see the [blog post](https://dolby.io/blog/generate-access-tokens-using-aws-services).

## You Will Need:

✅ Dolby.io Interactivity key and secret - sign up at [Dolby.io](dolby.io)

✅ Access to AWS service Console - signed in as IAM User with access to Lambda and API Gateway

✅ Have [AWS Command Line Interface (CLI)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) Installed and [AWS Credentials Configured](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)

### 📁 0-set-up-local-authentication-server-and-client

Run a local Express server to get an access token from the Interactivity API. Includes sample client code to test server.

```

0-set-up-local-authentication-server-and-client
├── client
│   ├── app.js
│   └── index.html
└── server
    ├── index.js
    └── example.env
```

#### 🚀 To run:

Within `/server`:

1. install dependencies

```
npm init -y
npm install axios express dotenv cors
```

2. create a .env file and replace with your own Interactivity key and secret (see .example.env)

```
CONSUMER_KEY=your_key
CONSUMER_SECRET=your_secret
```

3. start server with `node index.js`. You should see "Listening at http://localhost:3001" in the console, indicating that the authentication server is ready for requests.

You can then open `client/index.html` in the browser to test calling the server.

### 📁 0-client

Contains just the front end client code to test either a local server or test the server on AWS services.

```
0-client
└── client
    ├── app.js
    └── index.html
```

Replace `tokenUrl` with the invoke url of your server.

### 📁 1-lambda-function

This is the Express authentication server code modified to comply with AWS syntax.

```
1-lambda-function
└── index.js
```

A deployment package with the needed dependencies needs to be created before uploading to the AWS console as a zip file.

To do so, within `1-lambda-function`, run:

```
npm init -y
npm install axios
```

Then, zip up the contents of the directory. The Lambda function is now ready to be uploaded to AWS.

### 📁 3-bash-script

This script programmatically creates the Lambda function and API Gateway for you.
It contains a `fetch_token.zip` file that contains the Lambda function from section `1-lambda-function` with the dependecy axios installed, and zipped up as a deployment package.

#### To run this script you will need:

✅ ARN for the Role you want to use to grant to your Lambda function

> run `create_fetch_token_iam_role.sh` to create an ARN Role if you do not have one. This creates an execution role and attached the role policy to give the Lambda function permissions as a service role

✅ Interactivity Consumer Key

✅ Interactivity Consumer Secret

👉 _Optional_: name for function (default is fetchInteractivityToken)

👉 _Optional_: region (default is us-west-1)

```
# these commands assume you are running them within /3-bash-script
# get ARN for Role (if you don't already have one)

./create_fetch_token_iam_role.sh

# returns:

Created a new role called FetchInteractivityTokenRole. The ARN for this is: ROLE_ARN

# create Lambda and API Gateway Setup to get Invoke URL for access token
# function name and region are optional

./aws_setup.sh <ARN_ROLE> <CONSUMER_KEY> <CONSUMER_SECRET> <-n FUNCTION_NAME> <-o REGION>

# returns:

URL to use to GET interactivity access token:
https://XXXXXXXXXX.execute-api.REGION.amazonaws.com/prod/token
```
