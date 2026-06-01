const crypto = require('crypto');
const DynamoDBRepository = require('./shared/src/dynamodb-client');
const ApiResponse = require('./shared/src/response');
const Validator = require('./shared/src/validator');
const { NotFoundError } = require('./shared/src/errors');
const { jsonBody, routeKey, wrap } = require('./shared/src/http');

const products = new DynamoDBRepository(process.env.PRODUCTS_TABLE);

exports.handler = wrap(async (event) => {
  const route = routeKey(event);
  const productId = event.pathParameters?.id;

  if (route === 'GET /products') {
    const result = await products.scan();
    return ApiResponse.success(result.items);
  }

  if (route === 'GET /products/{id}') {
    const product = await products.get({ product_id: productId });
    if (!product) throw new NotFoundError('Product');
    return ApiResponse.success(product);
  }

  if (route === 'POST /products') {
    const body = jsonBody(event);
    Validator.validateRequired(body.name, 'name');
    const product = {
      product_id: crypto.randomUUID(),
      name: body.name,
      category: body.category || 'uncategorized',
      price: Validator.validateNumber(body.price, 'price', { min: 0 }),
      stock_quantity: Number(body.stock_quantity || 0),
      image_url: body.image_url || null,
      created_at: new Date().toISOString()
    };
    await products.put(product);
    return ApiResponse.success(product, 201, 'Product created');
  }

  if (route === 'PUT /products/{id}') {
    const product = await products.update({ product_id: productId }, jsonBody(event));
    return ApiResponse.success(product, 200, 'Product updated');
  }

  if (route === 'DELETE /products/{id}') {
    await products.delete({ product_id: productId });
    return ApiResponse.success({}, 200, 'Product deleted');
  }

  return ApiResponse.error(new Error(`Unsupported route: ${route}`), 404);
});
