"use strict";

exports.handler = async () => ({
  statusCode: 503,
  headers: {
    "content-type": "application/json"
  },
  body: JSON.stringify({
    error: "Service Unavailable",
    message: "Application deployment is pending."
  })
});
