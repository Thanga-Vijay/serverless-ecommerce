const handlers = require('./src/handlers');
const ApiResponse = require('./shared/src/response');

const routes = {
  'POST /auth/signup': handlers.signup,
  'POST /auth/login': handlers.login,
  'GET /auth/profile': handlers.getProfile,
  'POST /auth/logout': handlers.logout
};

exports.handler = async (event, context) => {
  const key = event.routeKey || `${event.requestContext?.http?.method} ${event.rawPath}`;
  return routes[key] ? routes[key](event, context) : ApiResponse.error(new Error(`Unsupported route: ${key}`), 404);
};

if (method === 'OPTIONS') {
  return {
    statusCode: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type,Authorization',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    },
    body: ''
  };
}

