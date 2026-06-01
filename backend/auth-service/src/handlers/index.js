const AuthService = require('../services/auth.service');
const ApiResponse = require('../../shared/src/response');
const Logger = require('../../shared/src/logger');
const { AppError } = require('../../shared/src/errors');

const logger = new Logger('auth-handlers');

exports.signup = async (event) => {
  try {
    const { email, password, firstName, lastName } = JSON.parse(event.body || '{}');
    const user = await AuthService.signup(email, password, firstName, lastName);
    logger.info('Signup handler success', { userId: user.id });
    return ApiResponse.success(user, 201, 'User registered successfully');
  } catch (error) {
    logger.error('Signup handler error', { error: error.message });
    return ApiResponse.error(error);
  }
};

exports.login = async (event) => {
  try {
    const { email, password } = JSON.parse(event.body || '{}');
    const user = await AuthService.login(email, password);
    const token = Buffer.from(JSON.stringify(user)).toString('base64');
    logger.info('Login handler success', { userId: user.id });
    return ApiResponse.success({ user, token }, 200, 'Login successful');
  } catch (error) {
    logger.error('Login handler error', { error: error.message });
    return ApiResponse.error(error);
  }
};

exports.getProfile = async (event) => {
  try {
    const userId = event.user?.userId || event.requestContext?.authorizer?.claims?.sub;
    if (!userId) {
      throw new AppError('User not authenticated', 401, 'AUTH_ERROR');
    }
    const user = await AuthService.getProfile(userId);
    logger.info('Get profile handler success', { userId });
    return ApiResponse.success(user, 200, 'Profile retrieved');
  } catch (error) {
    logger.error('Get profile handler error', { error: error.message });
    return ApiResponse.error(error);
  }
};

exports.logout = async (event) => {
  try {
    const userId = event.user?.userId;
    logger.info('User logout', { userId });
    return ApiResponse.success({}, 200, 'Logout successful');
  } catch (error) {
    logger.error('Logout handler error', { error: error.message });
    return ApiResponse.error(error);
  }
};
