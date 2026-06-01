const DynamoDBRepository = require('./shared/src/dynamodb-client');
const ApiResponse = require('./shared/src/response');
const Validator = require('./shared/src/validator');
const { jsonBody, routeKey, userId, wrap } = require('./shared/src/http');

const cart = new DynamoDBRepository(process.env.CART_TABLE);

exports.handler = wrap(async (event) => {
  const route = routeKey(event);
  const customerId = userId(event);

  if (route === 'GET /cart') {
    const result = await cart.query('user_id = :user_id', { ':user_id': customerId });
    return ApiResponse.success(result.items);
  }

  if (route === 'POST /cart/items') {
    const body = jsonBody(event);
    Validator.validateRequired(body.product_id, 'product_id');
    const item = {
      user_id: customerId,
      product_id: body.product_id,
      quantity: Validator.validateNumber(body.quantity || 1, 'quantity', { min: 1 }),
      expires_at: Math.floor(Date.now() / 1000) + 604800
    };
    await cart.put(item);
    return ApiResponse.success(item, 201, 'Cart item added');
  }

  if (route === 'DELETE /cart/items/{id}') {
    await cart.delete({ user_id: customerId, product_id: event.pathParameters.id });
    return ApiResponse.success({}, 200, 'Cart item removed');
  }

  return ApiResponse.error(new Error(`Unsupported route: ${route}`), 404);
});
