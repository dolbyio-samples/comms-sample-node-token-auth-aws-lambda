const BASE_URL = 'http://localhost:3001';
let tokenUrl = `${BASE_URL}/token`;

let accessTokenDiv = document.getElementById('access-token');

async function refreshVoxeetToken() {
  return fetch(tokenUrl);
}

async function getVoxeetToken() {
  // initializeToken authorization flow
  return fetch(tokenUrl)
    .then((res) => {
      return res.json();
    })
    .then(async (result) => {
      await VoxeetSDK.initializeToken(result.access_token, async () => {
        await refreshVoxeetToken();
      });
      accessTokenDiv.innerHTML = result.access_token;
    })
    .then(() => {
      console.log('token received');
    })
    .catch((error) => {
      console.log(error);
    });
}

async function initializeVoxeetSession() {
  try {
    await VoxeetSDK.session.open({
      name: 'test-name',
    });
    console.log('session initialized!');
  } catch (e) {
    alert('Something went wrong: ' + e);
  }
}

document.getElementById('get-token').onclick = getVoxeetToken;
document.getElementById('init-session').onclick = initializeVoxeetSession;
