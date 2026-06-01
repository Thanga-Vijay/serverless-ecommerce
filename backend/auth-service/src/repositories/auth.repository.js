const DynamoDBRepository = require('../../shared/src/dynamodb-client');
const Logger = require('../../shared/src/logger');
const crypto = require('crypto');

const logger = new Logger('auth-repository');

class AuthRepository extends DynamoDBRepository {
  constructor() {
    super(process.env.USERS_TABLE);
  }

  async findByEmail(email) {
    try {
      const result = await this.query(
        'email = :email',
        { ':email': email },
        { indexName: 'email-index' }
      );
      return result.items.length > 0 ? result.items[0] : null;
    } catch (error) {
      logger.error('Error finding user by email', { error: error.message });
      throw error;
    }
  }

  async findById(userId) {
    try {
      return await this.get({ user_id: userId });
    } catch (error) {
      logger.error('Error finding user by id', { error: error.message });
      throw error;
    }
  }

  async createUser(userData) {
    try {
      const user = {
        user_id: crypto.randomUUID(),
        email: userData.email,
        firstName: userData.firstName,
        lastName: userData.lastName,
        passwordHash: userData.passwordHash,
        role: 'user',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      await this.put(user);
      logger.info('User created', { userId: user.user_id, email: user.email });
      
      return user;
    } catch (error) {
      logger.error('Error creating user', { error: error.message });
      throw error;
    }
  }

  async updateLastLogin(userId) {
    try {
      const user = await this.update(
        { user_id: userId },
        { lastLogin: new Date().toISOString() }
      );
      return user;
    } catch (error) {
      logger.error('Error updating last login', { error: error.message });
      throw error;
    }
  }
}

module.exports = AuthRepository;
