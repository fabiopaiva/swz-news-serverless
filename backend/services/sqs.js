const AWS = require("./aws");

const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });

module.exports = {
  removeItem: (queueUrl, receiptHandle) =>
    new Promise((resolve, reject) => {
      const deleteParams = {
        QueueUrl: queueUrl,
        ReceiptHandle: receiptHandle,
      };
      sqs.deleteMessage(deleteParams, function (err, data) {
        if (err) {
          reject(err);
        } else {
          resolve("Message removed from queue", data);
        }
      });
    }),
  addItem: (queueUrl, body) =>
    new Promise((resolve, reject) => {
      const params = {
        MessageBody: body,
        QueueUrl: queueUrl,
      };
      sqs.sendMessage(params, function (err, data) {
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      });
    }),
};
