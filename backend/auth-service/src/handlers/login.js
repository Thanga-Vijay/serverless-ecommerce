const AuthService = require('../services/auth.service');
const Logger = require('../../shared/src/logger');
const { AppError } = require('../../shared/src/errors');

const logger = new Logger('login-handler');

const formatResponse = (statusCode, data) => ({
  statusCode,
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,Authorization'
  },
  body: JSON.stringify(data)
});

module.exports = async (event) => {
  try {
    const body = JSON.parse(event.body || '{}');
    const { email, password } = body;

    const user = await AuthService.login(email, password);

    logger.info('User login successful', { userId: user.id });
    return formatResponse(200, {
      data: user,
      message: 'Login successful'
    });
  } catch (error) {
    logger.error('Login handler error', { error: error.message });
    if (error instanceof AppError) {
      return formatResponse(error.statusCode, error.toJSON());
    }
    return formatResponse(500, {
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_SERVER_ERROR'
      }
    });
  }
};
