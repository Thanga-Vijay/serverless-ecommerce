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
