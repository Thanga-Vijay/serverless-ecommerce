const handlers = require('./src/handlers');

exports.handler = async (event) => {
  try {
    const method =
      event.requestContext?.http?.method ||
      event.httpMethod;

    const path =
      event.rawPath ||
      event.path;

    console.log('Incoming request:', { method, path });

    // HEALTH CHECK
    if (method === 'GET' && path === '/health') {
      return {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: 'healthy',
          service: 'auth-service'
        })
      };
    }

    // SIGNUP
    if (method === 'POST' && path === '/auth/register') {
      return await handlers.signup(event);
    }

    // LOGIN
    if (method === 'POST' && path === '/auth/login') {
      return await handlers.login(event);
    }

    // GET PROFILE
    if (method === 'GET' && path === '/auth/profile') {
      return await handlers.getProfile(event);
    }

    // LOGOUT
    if (method === 'POST' && path === '/auth/logout') {
      return await handlers.logout(event);
    }

    // ROUTE NOT FOUND
    return {
      statusCode: 404,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        error: {
          message: `Unsupported route: ${method} ${path}`,
          code: 'ROUTE_NOT_FOUND'
        }
      })
    };

  } catch (error) {
    console.error('Unhandled Lambda error:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        error: {
          message: 'Internal server error',
          code: 'INTERNAL_SERVER_ERROR'
        }
      })
    };
  }
};

