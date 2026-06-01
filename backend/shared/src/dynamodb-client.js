const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const {
  DeleteCommand,
  DynamoDBDocumentClient,
  GetCommand,
  PutCommand,
  QueryCommand,
  ScanCommand,
  UpdateCommand
} = require('@aws-sdk/lib-dynamodb');

const client = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: process.env.AWS_REGION }),
  { marshallOptions: { removeUndefinedValues: true } }
);

class DynamoDBRepository {
  constructor(tableName) {
    this.client = client;
    this.tableName = tableName;
  }

  async get(key) {
    const response = await this.client.send(new GetCommand({
      TableName: this.tableName,
      Key: key
    }));
    return response.Item || null;
  }

  async put(item, options = {}) {
    await this.client.send(new PutCommand({
      TableName: this.tableName,
      Item: item,
      ...options
    }));
    return item;
  }

  async update(key, updateData) {
    const fields = Object.entries(updateData);
    const names = {};
    const values = {};
    const assignments = fields.map(([field, value], index) => {
      names[`#field${index}`] = field;
      values[`:value${index}`] = value;
      return `#field${index} = :value${index}`;
    });

    const response = await this.client.send(new UpdateCommand({
      TableName: this.tableName,
      Key: key,
      UpdateExpression: `SET ${assignments.join(', ')}`,
      ExpressionAttributeNames: names,
      ExpressionAttributeValues: values,
      ReturnValues: 'ALL_NEW'
    }));
    return response.Attributes;
  }

  async delete(key) {
    await this.client.send(new DeleteCommand({
      TableName: this.tableName,
      Key: key
    }));
  }

  async query(keyConditionExpression, expressionAttributeValues, options = {}) {
    const response = await this.client.send(new QueryCommand({
      TableName: this.tableName,
      IndexName: options.indexName,
      KeyConditionExpression: keyConditionExpression,
      ExpressionAttributeValues: expressionAttributeValues,
      Limit: options.limit || 50,
      ExclusiveStartKey: options.startKey,
      ScanIndexForward: options.ascending !== false
    }));

    return {
      items: response.Items || [],
      count: response.Count || 0,
      lastEvaluatedKey: response.LastEvaluatedKey || null
    };
  }

  async scan(options = {}) {
    const response = await this.client.send(new ScanCommand({
      TableName: this.tableName,
      Limit: options.limit || 50,
      ExclusiveStartKey: options.startKey
    }));

    return {
      items: response.Items || [],
      count: response.Count || 0,
      lastEvaluatedKey: response.LastEvaluatedKey || null
    };
  }
}

module.exports = DynamoDBRepository;
