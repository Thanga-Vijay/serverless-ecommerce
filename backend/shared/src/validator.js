const { ValidationError } = require('./errors');

class Validator {
  static validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new ValidationError('Invalid email format', { email });
    }
    return email;
  }

  static validatePassword(password) {
    if (!password || password.length < 8) {
      throw new ValidationError('Password must be at least 8 characters');
    }
    return password;
  }

  static validateRequired(value, fieldName) {
    if (!value) {
      throw new ValidationError(`${fieldName} is required`, { field: fieldName });
    }
    return value;
  }

  static validateString(value, fieldName, options = {}) {
    if (typeof value !== 'string') {
      throw new ValidationError(`${fieldName} must be a string`, { field: fieldName });
    }

    if (options.minLength && value.length < options.minLength) {
      throw new ValidationError(
        `${fieldName} must be at least ${options.minLength} characters`,
        { field: fieldName }
      );
    }

    if (options.maxLength && value.length > options.maxLength) {
      throw new ValidationError(
        `${fieldName} must not exceed ${options.maxLength} characters`,
        { field: fieldName }
      );
    }

    return value;
  }

  static validateNumber(value, fieldName, options = {}) {
    const num = parseFloat(value);
    if (isNaN(num)) {
      throw new ValidationError(`${fieldName} must be a number`, { field: fieldName });
    }

    if (options.min !== undefined && num < options.min) {
      throw new ValidationError(`${fieldName} must be at least ${options.min}`, {
        field: fieldName
      });
    }

    if (options.max !== undefined && num > options.max) {
      throw new ValidationError(`${fieldName} must not exceed ${options.max}`, {
        field: fieldName
      });
    }

    return num;
  }

  static validateObject(obj, schema) {
    const errors = {};

    for (const [field, rules] of Object.entries(schema)) {
      try {
        const value = obj[field];

        if (rules.required && !value) {
          errors[field] = `${field} is required`;
          continue;
        }

        if (value && rules.type === 'email') {
          this.validateEmail(value);
        }

        if (value && rules.type === 'string') {
          this.validateString(value, field, rules);
        }

        if (value && rules.type === 'number') {
          this.validateNumber(value, field, rules);
        }
      } catch (error) {
        errors[field] = error.message;
      }
    }

    if (Object.keys(errors).length > 0) {
      throw new ValidationError('Validation failed', errors);
    }
  }
}

module.exports = Validator;
