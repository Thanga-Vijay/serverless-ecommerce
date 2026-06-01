class ApiResponse {
  static success(data, statusCode = 200, message = 'Success') {
    return {
      statusCode,
      body: JSON.stringify({
        success: true,
        message,
        data,
        timestamp: new Date().toISOString()
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization'
      }
    };
  }

  static error(error, statusCode = 500) {
    const response = error.toJSON?.() || {
      error: {
        message: error.message || 'Internal Server Error',
        code: 'INTERNAL_ERROR',
        statusCode
      }
    };

    return {
      statusCode: error.statusCode || statusCode,
      body: JSON.stringify(response),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization'
      }
    };
  }

  static paginated(items, page, limit, total, message = 'Success') {
    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message,
        data: items,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        },
        timestamp: new Date().toISOString()
      }),
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    };
  }
}

module.exports = ApiResponse;
