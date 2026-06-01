const { AuthError } = require('./errors');
const Logger = require('./logger');

const logger = new Logger('jwt-validator');

class JwtValidator {
  static extractToken(authHeader) {
    if (!authHeader) {
      throw new AuthError('Missing Authorization header');
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      throw new AuthError('Invalid Authorization header format');
    }

    return parts[1];
  }

  static decodeToken(token) {
    try {
      const parts = token.split('.');
      if (parts.length !== 3) {
        throw new AuthError('Invalid token format');
      }

      const payload = JSON.parse(
        Buffer.from(parts[1], 'base64').toString('utf-8')
      );

      return payload;
    } catch (error) {
      logger.error('Token decode error', { error: error.message });
      throw new AuthError('Invalid token');
    }
  }

  static async validateCognitoToken(token, cognitoUserPoolId) {
    try {
      const payload = this.decodeToken(token);

      // Check expiration
      if (payload.exp && payload.exp < Math.floor(Date.now() / 1000)) {
        throw new AuthError('Token expired');
      }

      // Verify issuer (basic check)
      const expectedIssuer = `https://cognito-idp.us-east-1.amazonaws.com/${cognitoUserPoolId}`;
      if (payload.iss !== expectedIssuer) {
        throw new AuthError('Invalid token issuer');
      }

      return payload;
    } catch (error) {
      throw new AuthError(error.message);
    }
  }

  static extractUserContext(payload) {
    return {
      userId: payload.sub,
      email: payload.email,
      role: payload['custom:role'] || 'user',
      username: payload['cognito:username'],
      tokenUse: payload.token_use
    };
  }
}

module.exports = JwtValidator;
