const Logger = require('../../shared/src/logger');

const logger = new Logger('logout-handler');

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
    logger.info('User logout successful');
    return formatResponse(200, {
      message: 'Logout successful'
    });
  } catch (error) {
    logger.error('Logout handler error', { error: error.message });
    return formatResponse(500, {
      error: {
        message: 'Internal server error',
        code: 'INTERNAL_SERVER_ERROR'
      }
    });
  }
};
