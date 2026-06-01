const JwtValidator = require('./jwt-validator');
const { AuthError } = require('./errors');
const Logger = require('./logger');

const logger = new Logger('auth-middleware');

const authMiddleware = async (event) => {
  try {
    const authHeader = event.headers?.authorization || event.headers?.Authorization;
    const token = JwtValidator.extractToken(authHeader);
    const payload = JwtValidator.decodeToken(token);
    const userContext = JwtValidator.extractUserContext(payload);

    logger.info('User authenticated', { userId: userContext.userId });

    return {
      isAuthorized: true,
      user: userContext,
      token: payload
    };
  } catch (error) {
    logger.error('Authentication failed', { error: error.message });
    throw new AuthError(error.message);
  }
};

const requireAuth = (handler) => {
  return async (event, context) => {
    try {
      const auth = await authMiddleware(event);
      event.user = auth.user;
      event.token = auth.token;
      return await handler(event, context);
    } catch (error) {
      throw error;
    }
  };
};

const requireRole = (requiredRole) => {
  return (handler) => {
    return async (event, context) => {
      try {
        const auth = await authMiddleware(event);
        
        if (auth.user.role !== requiredRole) {
          throw new AuthError(`Required role: ${requiredRole}`);
        }

        event.user = auth.user;
        event.token = auth.token;
        return await handler(event, context);
      } catch (error) {
        throw error;
      }
    };
  };
};

module.exports = {
  authMiddleware,
  requireAuth,
  requireRole
};
