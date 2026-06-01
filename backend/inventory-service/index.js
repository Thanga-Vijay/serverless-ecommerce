const DynamoDBRepository = require('./shared/src/dynamodb-client');

const inventory = new DynamoDBRepository(process.env.INVENTORY_TABLE);

exports.handler = async (event) => {
  const failures = [];

  for (const record of event.Records || []) {
    try {
      const message = JSON.parse(record.body);
      const productId = message.product_id || message.productId;
      const quantity = Number(message.quantity || 0);
      const current = await inventory.get({ product_id: productId }) || {
        product_id: productId,
        available_stock: 0,
        reserved_stock: 0
      };
      await inventory.put({
        ...current,
        available_stock: Math.max(0, Number(current.available_stock) - quantity),
        reserved_stock: Number(current.reserved_stock) + quantity,
        updated_at: new Date().toISOString()
      });
    } catch {
      failures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures: failures };
};
