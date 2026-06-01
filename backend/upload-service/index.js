const crypto = require('crypto');
const { PutObjectCommand, S3Client } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const ApiResponse = require('./shared/src/response');
const { AppError } = require('./shared/src/errors');
const { jsonBody, wrap } = require('./shared/src/http');

const s3 = new S3Client({ region: process.env.AWS_REGION });
const allowedTypes = new Set(['image/jpeg', 'image/png', 'image/webp']);

exports.handler = wrap(async (event) => {
  const body = jsonBody(event);
  if (!allowedTypes.has(body.content_type)) {
    throw new AppError('Only JPEG, PNG, and WebP images are allowed', 400, 'INVALID_FILE_TYPE');
  }

  const extension = body.content_type.split('/')[1].replace('jpeg', 'jpg');
  const key = `products/${crypto.randomUUID()}.${extension}`;
  const uploadUrl = await getSignedUrl(s3, new PutObjectCommand({
    Bucket: process.env.IMAGES_BUCKET,
    Key: key,
    ContentType: body.content_type
  }), { expiresIn: 900 });

  return ApiResponse.success({ key, uploadUrl, expiresIn: 900 }, 200, 'Upload URL generated');
});
