"use strict";
const AWS = require("aws-sdk");
AWS.config.update({ region: "eu-central-1" });

const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
const ddb = new AWS.DynamoDB({ apiVersion: "2012-08-10" });

const Converter = AWS.DynamoDB.Converter;
const { marshall } = Converter;

module.exports.getNews = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify(
      {
        message: "Go Serverless v1.0! Your function executed successfully!",
        // input: event,
      },
      null,
      2
    ),
  };
};

module.exports.postNews = async (event) => {
  if (event.body.length > 256 * 1024) {
    // SQS configured limit
    return {
      statusCode: 400,
      body: JSON.stringify({
        errors: ["Message is too big"],
      }),
    };
  }

  let params;
  try {
    const { slug, title, date, description } = JSON.parse(event.body);
    if (!slug || !date) throw new Error("Slug and date are required");
    params = {
      MessageBody: JSON.stringify({ slug, title, date, description }),
      QueueUrl: process.env.SQS_QUEUE_URL,
    };
  } catch (e) {
    console.error(e);
    return {
      statusCode: 400,
      body: JSON.stringify({
        errors: ["Invalid body"],
        details: e.message,
      }),
    };
  }

  try {
    const { MessageId } = await new Promise((resolve, reject) => {
      sqs.sendMessage(params, function (err, data) {
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      });
    });
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "success",
        id: MessageId,
      }),
    };
  } catch (e) {
    console.error(e);
    return {
      statusCode: 500,
      body: JSON.stringify({
        errors: [e.message],
      }),
    };
  }
};

module.exports.postNewsConsumer = async (event) => {
  await Promise.all(
    event.Records.map(
      (record) =>
        new Promise(async (resolve, reject) => {
          const { messageId, body, receiptHandle } = record;
          console.log("Processing", { messageId, body });
          await new Promise((resolve, reject) => {
            const ddbPutParams = {
              TableName: process.env.NEWS_TABLE_NAME,
              Item: marshall(JSON.parse(body)),
              ReturnValues: "NONE",
            };
            ddb.putItem(ddbPutParams, (err, data) => {
              if (err) {
                console.error("Error persisting", { messageId, err });
                reject(err);
              } else {
                console.log("Success persisting", { messageId });
                resolve(data);
              }
            });
          });

          const deleteParams = {
            QueueUrl: process.env.SQS_QUEUE_URL,
            ReceiptHandle: receiptHandle,
          };
          sqs.deleteMessage(deleteParams, function (err, data) {
            if (err) {
              console.error("Error processing", { messageId, err });
              reject(err);
            } else {
              console.log("Success processing", { messageId });
              resolve("Message Deleted", data);
            }
          });
        })
    )
  );
};
