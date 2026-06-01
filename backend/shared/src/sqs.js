const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const client = new SQSClient({ region: process.env.AWS_REGION });

const sendMessage = async (queueUrl, message) => {
  if (!queueUrl) return;
  await client.send(new SendMessageCommand({
    QueueUrl: queueUrl,
    MessageBody: JSON.stringify(message)
  }));
};

module.exports = { sendMessage };
