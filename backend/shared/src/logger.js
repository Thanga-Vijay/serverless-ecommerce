const LOG_LEVELS = {
  DEBUG: 'DEBUG',
  INFO: 'INFO',
  WARN: 'WARN',
  ERROR: 'ERROR',
  FATAL: 'FATAL'
};

class Logger {
  constructor(service) {
    this.service = service;
  }

  log(level, message, metadata = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      service: this.service,
      message,
      ...metadata,
      requestId: process.env.AWS_REQUEST_ID
    };

    console.log(JSON.stringify(logEntry));
  }

  debug(message, metadata) {
    this.log(LOG_LEVELS.DEBUG, message, metadata);
  }

  info(message, metadata) {
    this.log(LOG_LEVELS.INFO, message, metadata);
  }

  warn(message, metadata) {
    this.log(LOG_LEVELS.WARN, message, metadata);
  }

  error(message, metadata) {
    this.log(LOG_LEVELS.ERROR, message, metadata);
  }

  fatal(message, metadata) {
    this.log(LOG_LEVELS.FATAL, message, metadata);
  }
}

module.exports = Logger;
