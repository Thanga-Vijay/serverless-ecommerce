const AuthService = require('../services/auth.service');
const Logger = require('../../shared/src/logger');
const { AppError } = require('../../shared/src/errors');

const logger = new Logger('getProfile-handler');

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
    const userId = event.pathParameters?.userId;
    if (!userId) {
      return formatResponse(400, {
        error: {
          message: 'User ID is required',
          code: 'MISSING_USER_ID'
        }
      });
    }

    const user = await AuthService.getProfile(userId);

    logger.info('Profile fetched successfully', { userId });
    return formatResponse(200, {
      data: user,
      message: 'Profile fetched successfully'
    });
  } catch (error) {
    logger.error('Get profile handler error', { error: error.message });
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
