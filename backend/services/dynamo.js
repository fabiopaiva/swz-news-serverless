const AWS = require("./aws");

const ddb = new AWS.DynamoDB({ apiVersion: "2012-08-10" });

const Converter = AWS.DynamoDB.Converter;
const { marshall, unmarshall } = Converter;

module.exports = {
  insert: (tableName, data) =>
    new Promise((resolve, reject) => {
      const ddbPutParams = {
        TableName: tableName,
        Item: marshall(data),
        ReturnValues: "NONE",
      };
      ddb.putItem(ddbPutParams, (err, data) => {
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      });
    }),
  scan: (tableName) =>
    new Promise((resolve, reject) => {
      const params = {
        TableName: tableName,
      };
      ddb.scan(params, (err, data) => {
        if (err) return reject(err);
        return resolve(data.Items.map((item) => unmarshall(item))); // for now ignore pagination
      });
    }),
  scanWithFilter: (tableName, { filterExpression, expressionAttributeNames, expressionAttributeValues }) =>
    new Promise((resolve, reject) => {
      const params = {
        TableName: tableName,
        ExpressionAttributeNames: expressionAttributeNames,
        ExpressionAttributeValues: expressionAttributeValues,
        FilterExpression: filterExpression,
      };
      console.log(params);
      ddb.scan(params, (err, data) => {
        if (err) return reject(err);
        console.log({ data: JSON.stringify(data, null, 2) });
        const [result] = data.Items;
        return resolve(unmarshall(result));
      });
    }),
  marshall,
};
