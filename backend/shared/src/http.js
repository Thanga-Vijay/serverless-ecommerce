const ApiResponse = require('./response');
const { AppError, AuthError } = require('./errors');

const jsonBody = (event) => {
  try {
    return JSON.parse(event.body || '{}');
  } catch {
    throw new AppError('Request body must be valid JSON', 400, 'INVALID_JSON');
  }
};

const routeKey = (event) => event.routeKey ||
  `${event.requestContext?.http?.method || event.httpMethod} ${event.rawPath || event.path}`;

const userId = (event) => {
  const id = event.requestContext?.authorizer?.jwt?.claims?.sub ||
    event.requestContext?.authorizer?.claims?.sub ||
    event.user?.userId;
  if (!id) throw new AuthError('Authenticated user ID is missing');
  return id;
};

const wrap = (handler) => async (event, context) => {
  try {
    return await handler(event, context);
  } catch (error) {
    return ApiResponse.error(error);
  }
};

module.exports = { jsonBody, routeKey, userId, wrap };
