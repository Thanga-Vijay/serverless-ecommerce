const crypto = require('crypto');
const DynamoDBRepository = require('./shared/src/dynamodb-client');
const ApiResponse = require('./shared/src/response');
const Validator = require('./shared/src/validator');
const { NotFoundError } = require('./shared/src/errors');
const { jsonBody, routeKey, userId, wrap } = require('./shared/src/http');
const { sendMessage } = require('./shared/src/sqs');

const orders = new DynamoDBRepository(process.env.ORDERS_TABLE);

exports.handler = wrap(async (event) => {
  const route = routeKey(event);
  const customerId = userId(event);

  if (route === 'POST /orders') {
    const body = jsonBody(event);
    Validator.validateRequired(body.items, 'items');
    const order = {
      order_id: crypto.randomUUID(),
      user_id: customerId,
      items: body.items,
      order_status: 'pending',
      payment_status: 'pending',
      total_amount: Validator.validateNumber(body.total_amount, 'total_amount', { min: 0 }),
      created_at: new Date().toISOString()
    };
    await orders.put(order);
    for (const item of body.items) {
      await sendMessage(process.env.INVENTORY_UPDATE_QUEUE, {
        type: 'RESERVE_INVENTORY',
        product_id: item.product_id,
        quantity: item.quantity
      });
    }
    await sendMessage(process.env.PAYMENT_PROCESSING_QUEUE, { type: 'PROCESS_PAYMENT', order });
    return ApiResponse.success(order, 201, 'Order created');
  }

  if (route === 'GET /orders/{id}') {
    const order = await orders.get({ order_id: event.pathParameters.id });
    if (!order) throw new NotFoundError('Order');
    return ApiResponse.success(order);
  }

  if (route === 'GET /orders/user') {
    const result = await orders.query('user_id = :user_id', { ':user_id': customerId }, {
      indexName: 'user-orders-index',
      ascending: false
    });
    return ApiResponse.success(result.items);
  }

  return ApiResponse.error(new Error(`Unsupported route: ${route}`), 404);
});
