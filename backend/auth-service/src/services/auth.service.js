const AuthRepository = require('../repositories/auth.repository');
const { AuthError, ConflictError, NotFoundError } = require('../../shared/src/errors');
const Validator = require('../../shared/src/validator');
const Logger = require('../../shared/src/logger');
const crypto = require('crypto');

const logger = new Logger('auth-service');
const repository = new AuthRepository();

class AuthService {
  static hashPassword(password) {
    return crypto
      .createHash('sha256')
      .update(password + process.env.PASSWORD_SALT)
      .digest('hex');
  }

  static verifyPassword(password, hash) {
    const computed = this.hashPassword(password);
    return computed === hash;
  }

  static async signup(email, password, firstName, lastName) {
    try {
      Validator.validateEmail(email);
      Validator.validatePassword(password);
      Validator.validateString(firstName, 'firstName', { minLength: 1 });
      Validator.validateString(lastName, 'lastName', { minLength: 1 });

      const existingUser = await repository.findByEmail(email);
      if (existingUser) {
        throw new ConflictError('Email already registered');
      }

      const passwordHash = this.hashPassword(password);
      const user = await repository.createUser({
        email,
        firstName,
        lastName,
        passwordHash
      });

      logger.info('User signup successful', { userId: user.id });

      return {
        id: user.user_id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role
      };
    } catch (error) {
      logger.error('Signup error', { error: error.message, email });
      throw error;
    }
  }

  static async login(email, password) {
    try {
      Validator.validateEmail(email);
      Validator.validateRequired(password, 'password');

      const user = await repository.findByEmail(email);
      if (!user) {
        throw new AuthError('Invalid credentials');
      }

      if (!this.verifyPassword(password, user.passwordHash)) {
        throw new AuthError('Invalid credentials');
      }

      await repository.updateLastLogin(user.user_id);

      logger.info('User login successful', { userId: user.id });

      return {
        id: user.user_id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role
      };
    } catch (error) {
      logger.error('Login error', { error: error.message, email });
      throw error;
    }
  }

  static async getProfile(userId) {
    try {
      const user = await repository.findById(userId);
      if (!user) {
        throw new NotFoundError('User');
      }

      return {
        id: user.user_id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        createdAt: user.createdAt
      };
    } catch (error) {
      logger.error('Get profile error', { error: error.message, userId });
      throw error;
    }
  }
}

module.exports = AuthService;
