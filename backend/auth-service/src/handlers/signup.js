const AuthService = require('../services/auth.service');
const Logger = require('../../shared/src/logger');
const { AppError } = require('../../shared/src/errors');

const logger = new Logger('signup-handler');

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
    const { email, password, firstName, lastName } = body;

    const user = await AuthService.signup(email, password, firstName, lastName);

    logger.info('User signup successful', { userId: user.id });
    return formatResponse(201, {
      data: user,
      message: 'User registered successfully'
    });
  } catch (error) {
    logger.error('Signup handler error', { error: error.message });
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
