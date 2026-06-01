const DynamoDBRepository = require('./shared/src/dynamodb-client');
const { sendMessage } = require('./shared/src/sqs');

const orders = new DynamoDBRepository(process.env.ORDERS_TABLE);

exports.handler = async (event) => {
  const failures = [];

  for (const record of event.Records || []) {
    try {
      const message = JSON.parse(record.body);
      const order = message.order || message;
      await orders.update({ order_id: order.order_id }, {
        payment_status: 'completed',
        order_status: 'processing',
        updated_at: new Date().toISOString()
      });
      await sendMessage(process.env.NOTIFICATION_QUEUE, {
        type: 'PAYMENT_COMPLETED',
        order_id: order.order_id,
        user_id: order.user_id
      });
    } catch {
      failures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures: failures };
};
