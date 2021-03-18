// express server
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

const CONSUMER_KEY = process.env.CONSUMER_KEY;
const CONSUMER_SECRET = process.env.CONSUMER_SECRET;
const PORT = 3001;
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
  let result = await axios.post(url, {}, config);
  return result.data;
}

app.get('/token', async (req, res) => {
  let response = await fetchToken();
  return res.json(response);
});

app.listen(PORT, () => console.log(`Listening at http://localhost:${PORT}`));
