const { PublishCommand, SNSClient } = require('@aws-sdk/client-sns');

const sns = new SNSClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
  const failures = [];

  for (const record of event.Records || []) {
    try {
      const message = JSON.parse(record.body);
      await sns.send(new PublishCommand({
        TopicArn: process.env.ORDER_NOTIFICATIONS_TOPIC,
        Subject: `Ecommerce event: ${message.type || 'NOTIFICATION'}`,
        Message: JSON.stringify(message)
      }));
    } catch {
      failures.push({ itemIdentifier: record.messageId });
    }
  }

  return { batchItemFailures: failures };
};
