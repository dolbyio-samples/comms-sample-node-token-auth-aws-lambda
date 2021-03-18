const axios = require('axios');
const CONSUMER_KEY = process.env.CONSUMER_KEY;
const CONSUMER_SECRET = process.env.CONSUMER_SECRET;
const credentials = new Buffer.from(
  CONSUMER_KEY + ':' + CONSUMER_SECRET
).toString('base64');
const url = 'https://session.voxeet.com/v1/oauth2/token';
const config = {
  headers: {
    Authorization: 'Basic ' + credentials,
  },
  body: { grant_type: 'client_credentials' },
};

async function fetchToken() {
  const token = {};
  const res = {};
  await axios
    .post(url, {}, config)
    .then(function (response) {
      token.access_token = response.data.access_token;
      token.refresh_token = response.data.refresh_token;
      res.statusCode = 200;
      res.headers = {
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Origin': '*', // NOTE this is to allow for CORS when testing locally
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
      };
      res.body = JSON.stringify(token);
    })
    .catch(function (error) {
      // handle error
      console.log(error);
    });
  return res;
}

exports.handler = async (event) => {
  let response = await fetchToken();
  return response;
};
